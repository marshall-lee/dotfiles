dir_overrides = {}

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  lazy = false,
  opts = function()        
    return {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    }
  end,
  config = function(_spec, opts)
    vim.api.nvim_create_autocmd("LspAttach", { callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if not client then return end

      local tb = require("telescope.builtin")

      vim.keymap.set("n", "gd", function() tb.lsp_definitions({ reuse_win = true }) end, { buffer = bufnr, desc = "Goto Definition" })

      if client.server_capabilities.referencesProvider then
        vim.keymap.set("n", "gr", function()
          vim.notify("Finding references...", vim.log.levels.INFO, { id = "lsp_refs" })
          vim.lsp.buf.references(nil, { loclist = true })
        end, { buffer = bufnr, desc = "References" })

        vim.keymap.set("n", "gR", function()
          vim.notify("Finding references...", vim.log.levels.INFO, { id = "lsp_refs" })
          tb.lsp_references()
        end, { buffer = bufnr, desc = "References (Telescope)" })
      end

      if client.server_capabilities.implementationProvider then
        vim.keymap.set("n", "gi", tb.lsp_implementations, { buffer = bufnr, desc = "Goto Implementation" })
      end

      if client.server_capabilities.typeDefinitionProvider then
        vim.keymap.set("n", "gt", tb.lsp_type_definitions, { buffer = bufnr, desc = "Type Definition" })
      end

      vim.keymap.set("n", "<leader>ss", tb.lsp_document_symbols, { buffer = bufnr, desc = "Document Symbols" })
      vim.keymap.set("n", "<leader>sS", tb.lsp_dynamic_workspace_symbols, { buffer = bufnr, desc = "Workspace Symbols" })
      vim.keymap.set("n", "<leader>sd", tb.diagnostics, { buffer = bufnr, desc = "Diagnostics" })

      vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
      vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = bufnr, desc = "Signature Help" })

      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code Action" })
      vim.keymap.set("n", "<leader>f", function()
        vim.notify("Formatting the code...", vim.log.levels.INFO, { id = "lsp_formatting" })
        vim.lsp.buf.format({ async = true })
      end, { buffer = bufnr, desc = "Format" })

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Prev Diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Next Diagnostic" })
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { buffer = bufnr, desc = "Line Diagnostics" })
    end })
    for server, config in pairs(opts.servers) do
      config = vim.tbl_extend("force", {}, config)
      config.capabilities = vim.tbl_deep_extend(
        "force",
        {},
        opts.capabilities or {},
        config.capabilities or {}
      )
      local runtime_config = config.runtime_config
      config.runtime_config = nil
      vim.lsp.config(server, config)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = vim.lsp.config[server].filetypes,
        callback = function(ev)
          local filename = vim.api.nvim_buf_get_name(ev.buf)
          local bufdir = vim.fs.normalize(vim.fs.dirname(filename))
          local bufdir_trailing_slash = bufdir .. "/"
          local new_config = vim.deepcopy(vim.lsp.config[server])
          if new_config.root_markers then
            new_config.root_dir = vim.fs.root(ev.buf, new_config.root_markers)
            new_config.root_markers = nil
          end
          local server_overrides = dir_overrides[server] or {}
          local overriden_dirs = vim.tbl_keys(server_overrides)
          table.sort(overriden_dirs)
          for _, dir in ipairs(overriden_dirs) do
            local override = server_overrides[dir]

            if next(override) ~= nil then
              local dir_trailing_slash = dir .. "/" 
              if bufdir_trailing_slash:sub(1, #dir_trailing_slash) == dir_trailing_slash then
                new_config = vim.tbl_extend("force", new_config, override)
              end
            end
          end
          if runtime_config then
            runtime_config(new_config)
          end
          vim.lsp.start(new_config, { bufnr = ev.buf })
        end,
      })
    end
  end,
  exrc_override = function(server, override_config)
    local info = debug.getinfo(2, "S")
    local source = info.source
    local filepath = source:sub(2) -- strip leading "@"
    local exrc_dir = vim.fs.dirname(vim.fs.normalize(filepath))
    dir_overrides[server] = dir_overrides[server] or {}
    dir_overrides[server][exrc_dir] = override_config
  end,
}
