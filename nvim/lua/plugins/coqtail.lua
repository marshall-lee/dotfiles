return {
  {
    "whonore/Coqtail",
    ft = "coq",
    config = function()
      vim.g.coqtail_nomap = 1
      -- ensure we set mappings only for Coq buffers
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = "coq",
        callback = function()
          local opts = { noremap = true, silent = true, buffer = true }

          vim.keymap.set("n", "<localleader>]", function()
            vim.cmd("RocqNext")
            vim.cmd("RocqJumpToEnd")
          end, opts)
          vim.keymap.set("n", "<localleader>[", function()
            vim.cmd("RocqUndo")
            vim.cmd("RocqJumpToEnd")
          end, opts)
          vim.keymap.set("n", "<localleader>.", "<cmd>RocqToLine<CR>", opts)
          vim.keymap.set("n", "gl", "<cmd>RocqJumpToEnd<CR>", opts)
          vim.keymap.set("n", "gd", function()
            local id = vim.fn.shellescape(vim.fn.expand("<cword>"))
            if id:match("^'.*'$") or id:match('^".*"$') then
              id = id:sub(2, -2)
            end
            vim.cmd("RocqGotoDef " .. id)
          end, opts)
        end,
      })
    end,
  },
}
