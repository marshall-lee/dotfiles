-- Sets the terminal title to the current file's name, which tmux shows in the
-- tab. Special buffers (Telescope, help, terminals) keep the previous file's
-- name, so the tab doesn't change while searching.
vim.opt.title = true

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost" }, {
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    local name = vim.api.nvim_buf_get_name(args.buf)
    name = name == "" and "[No Name]" or vim.fs.basename(name)
    -- titlestring treats % as the start of a format item.
    vim.opt.titlestring = (name:gsub("%%", "%%%%"))
  end,
})
