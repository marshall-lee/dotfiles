return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  opts = {
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
    },
  },
  config = function()
    local telescope = require("telescope")
    telescope.load_extension('fzf')

    local builtin = require("telescope.builtin")
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = 'Telescope recent files' })
    vim.keymap.set("n", "<leader>fR", function() builtin.oldfiles({ initial_mode = "normal" }) end, { desc = 'Telescope recent files (normal mode)' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fG', function()
      local Path = require("plenary.path")
      local path = Path:new(vim.fn.expand('%:p'))
      if not path:exists() then path = Path:new(vim.loop.cwd()) end
      local gitroot = vim.tbl_filter(function(parent)
        return Path:new(parent .. '/.git'):is_dir()
      end, path:parents())[1]
      if gitroot then
        builtin.live_grep({ cwd = gitroot })
      else
        vim.notify("git repo is not found", vim.log.levels.ERROR)
      end
    end, { desc = 'Telescope live grep (git repo)' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope search word under cursor' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fB', function() builtin.buffers({ initial_mode = "normal" }) end, { desc = 'Telescope buffers (normal mode)' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    vim.keymap.set("n", "<leader>tr", builtin.resume, { desc = 'Telescope resume' })
    vim.keymap.set("n", "<leader>tR", function() builtin.resume({ initial_mode = "normal" }) end, { desc = 'Telescope resume (normal mode)' })
  end,
}
