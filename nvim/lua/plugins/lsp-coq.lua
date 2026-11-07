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
        return doc.spans
      end

      -- Convert an LSP position { line (0-based), character } to a Neovim
      -- cursor { line (1-based), col (0-based) }. Assumes ASCII (typical for
      -- Coq), so the character offset equals the byte offset.
      local function pos_to_cursor(bufnr, pos)
        local line_text = vim.api.nvim_buf_get_lines(bufnr, pos.line, pos.line + 1, false)[1] or ""
        return { pos.line + 1, math.min(pos.character, #line_text) }
      end

      -- true if (a_line, a_col) is strictly after (b_line, b_col)
      local function after(a_line, a_col, b_line, b_col)
        return a_line > b_line or (a_line == b_line and a_col > b_col)
      end

      local function jump(direction)
        local bufnr = 0
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
      end

      -- Buffer-local keybindings, matching the old Coqtail layout.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "coq",
        callback = function()
          local opts = { noremap = true, silent = true, buffer = true }
          vim.keymap.set("n", "<localleader>]", function() jump("next") end, { desc = "Next Coq statement" })
          vim.keymap.set("n", "<localleader>[", function() jump("prev") end, { desc = "Previous Coq statement" })
          vim.keymap.set("n", "<localleader>i", function()
            local bufnr = 0
            local client = vim.lsp.get_clients({ bufnr = bufnr, name = "coq_lsp" })[1]
            if not client then
              vim.notify("coq-lsp not attached", vim.log.levels.WARN)
              return
            end
            local wrapper = require("coq-lsp").clients[client.id]
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
