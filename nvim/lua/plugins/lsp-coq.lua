return {
  {
    "whonore/Coqtail",
    ft = "coq",
    -- Keep Coqtail for syntax highlighting, ftdetect and basic ftplugin,
    -- but stop it from activating its interactive proof features.
    config = function()
      vim.g.loaded_coqtail = 1
      vim.g['coqtail#supported'] = 0
    end,
  },
  {
    "tomtomjhj/coq-lsp.nvim",
    ft = "coq",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    build = "./scripts/build.sh",
    opts = {
      coq_lsp_nvim = {
        info_panel_mode = "tab",
        info_panel_sticky_close = true,
      },
      lsp = {
        -- No on_attach needed: your lsp.lua LspAttach autocmd already
        -- provides all the standard LSP keybindings (gd, gr, K, etc.).
        init_options = {
          show_notices_as_diagnostics = true,
        },
        autostart = false, -- start with :LspStart when needed
      },
    },
    config = function(_spec, opts)
      local coq_lsp = require("coq-lsp")
      coq_lsp.setup(opts)

      -- Cache for statement spans per buffer
      local span_cache = {}

      -- Namespace for "checked" highlighting (everything before cursor)
      local checked_ns = vim.api.nvim_create_namespace("coq-checked")

      -- Setup per-buffer state
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "coq",
        callback = function(ev)
          local bufnr = ev.buf

          -- Buffer-local invalidation
          vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufReadPost" }, {
            buffer = bufnr,
            callback = function()
              span_cache[bufnr] = nil
              -- Clear highlights on edit since spans may change
              vim.api.nvim_buf_clear_namespace(bufnr, checked_ns, 0, -1)
            end,
          })
        end,
      })

      -- Statement navigation.
      --
      -- A Coq program is a sequence of statements, each terminated by ".",
      -- but a naive regex can't find those boundaries reliably: statements
      -- can be nested and strings/parenthesized terms can contain ".".
      --
      -- Instead of parsing, we ask the coq-lsp server for its real parsed
      -- document (`coq/getDocument`). Flèche is a genuine Coq parser, so the
      -- returned spans already have correct boundaries. We just jump the
      -- cursor between them and let coq-lsp show the goals at that point.

      -- Fetch the list of statement spans from the server.
      local function get_spans(bufnr)
        -- Check cache first
        if span_cache[bufnr] then
          return span_cache[bufnr]
        end

        local client = vim.lsp.get_clients({ bufnr = bufnr, name = "coq_lsp" })[1]
        if not client then
          vim.notify("coq-lsp is not attached (try :LspStart)", vim.log.levels.WARN)
          return nil
        end
        local wrapper = coq_lsp.clients[client.id]
        if not wrapper then
          vim.notify("coq-lsp client wrapper not found", vim.log.levels.WARN)
          return nil
        end
        local doc = wrapper:get_document(bufnr)
        if type(doc) ~= "table" or type(doc.spans) ~= "table" then
          return nil
        end

        -- Cache the result
        span_cache[bufnr] = doc.spans
        return doc.spans
      end

      -- Convert an LSP position { line (0-based), character } to a Neovim
      -- position for vim.hl.range: { line (0-based), col (0-based) }.
      -- vim.hl.range uses 0-based lines!
      local function pos_to_hl(bufnr, pos)
        local line_text = vim.api.nvim_buf_get_lines(bufnr, pos.line, pos.line + 1, false)[1] or ""
        return { pos.line, math.min(pos.character, #line_text) }
      end

      -- Convert an LSP position { line (0-based), character } to a Neovim
      -- cursor { line (1-based), col (0-based) } for vim.api.nvim_win_set_cursor.
      local function pos_to_cursor(bufnr, pos)
        local line_text = vim.api.nvim_buf_get_lines(bufnr, pos.line, pos.line + 1, false)[1] or ""
        return { pos.line + 1, math.min(pos.character, #line_text) }
      end

      -- true if (a_line, a_col) is strictly after (b_line, b_col)
      local function after(a_line, a_col, b_line, b_col)
        return a_line > b_line or (a_line == b_line and a_col > b_col)
      end

      -- Highlight everything from start of file to cursor as "checked"
      local function update_checked_highlight(bufnr)
        local spans = get_spans(bufnr)
        if not spans or #spans == 0 then
          return
        end

        vim.api.nvim_buf_clear_namespace(bufnr, checked_ns, 0, -1)

        local win_cursor = vim.api.nvim_win_get_cursor(0)
        local cur_line = win_cursor[1] - 1  -- 0-based line
        local cur_col = win_cursor[2]       -- 0-based col

        -- Find the end position of the last completed statement (before/at cursor)
        local highlight_end = { 0, 0 }  -- Default to start of file
        for _, span in ipairs(spans) do
          local end_pos = span.range["end"]
          -- Check if this statement ends before or at cursor
          if end_pos.line < cur_line or (end_pos.line == cur_line and end_pos.character <= cur_col) then
            highlight_end = { end_pos.line, end_pos.character }
          end
        end

        -- Highlight from start of file to end of last completed statement
        if highlight_end[1] > 0 or highlight_end[2] > 0 then
          vim.hl.range(bufnr, checked_ns, "CoqtailChecked", { 0, 0 }, highlight_end, { priority = vim.hl.priorities.user })
        end
      end

      local function jump(direction)
        local bufnr = vim.api.nvim_get_current_buf()
        local spans = get_spans(bufnr)
        if not spans or #spans == 0 then
          return
        end
        local cur_line, cur_col = (vim.api.nvim_win_get_cursor(0)[1]) - 1, vim.api.nvim_win_get_cursor(0)[2]

        local target
        if direction == "next" then
          -- start of the next statement strictly after the cursor
          for _, span in ipairs(spans) do
            local s = span.range.start
            if after(s.line, s.character, cur_line, cur_col) then
              target = s
              break
            end
          end
        else
          -- start of the previous statement strictly before the cursor
          for i = #spans, 1, -1 do
            local s = spans[i].range.start
            if after(cur_line, cur_col, s.line, s.character) then
              target = s
              break
            end
          end
        end

        if not target then
          vim.notify(direction == "next" and "No next statement" or "No previous statement", vim.log.levels.INFO)
          return
        end

        vim.api.nvim_win_set_cursor(0, pos_to_cursor(bufnr, target))
        update_checked_highlight(bufnr)
      end

      -- Debounce timer for cursor-based highlight updates
      local highlight_timer = nil
      local function update_checked_debounced()
        if highlight_timer then
          highlight_timer:stop()
        end
        if not highlight_timer then
          highlight_timer = vim.uv.new_timer()
        end
        highlight_timer:start(100, 0, function()
          vim.schedule(function()
            local bufnr = vim.api.nvim_get_current_buf()
            if vim.bo[bufnr].filetype == "coq" then
              update_checked_highlight(bufnr)
            end
          end)
        end)
      end

      -- Buffer-local keybindings, matching the old Coqtail layout.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "coq",
        callback = function(ev)
          local bufnr = ev.buf

          -- Update "checked" highlight on cursor movement (debounced)
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = bufnr,
            callback = update_checked_debounced,
          })

          local opts = { noremap = true, silent = true, buffer = true }
          vim.keymap.set("n", "<localleader>]", function() jump("next") end, { desc = "Next Coq statement" })
          vim.keymap.set("n", "<localleader>[", function() jump("prev") end, { desc = "Previous Coq statement" })
          vim.keymap.set("n", "<localleader>i", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local client = vim.lsp.get_clients({ bufnr = bufnr, name = "coq_lsp" })[1]
            if not client then
              vim.notify("coq-lsp not attached", vim.log.levels.WARN)
              return
            end
            local wrapper = coq_lsp.clients[client.id]
            if not wrapper then
              vim.notify("coq-lsp client wrapper not found", vim.log.levels.WARN)
              return
            end
            wrapper:open_info_panel(bufnr)
          end, { desc = "Show Coq goals at cursor" })
        end,
      })
    end,
  },
}
