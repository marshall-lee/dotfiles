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
    vim.keymap.set("n", "<leader>fr", function() builtin.oldfiles({ initial_mode = "normal" }) end, { desc = 'Telescope recent files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Telescope search word under cursor' })
    vim.keymap.set('n', '<leader>fb', function() builtin.buffers({ initial_mode = "normal" }) end, { desc = 'Telescope buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    vim.keymap.set("n", "<leader>tr", function() builtin.resume({ initial_mode = "normal" }) end, { desc = 'Telescope resume' })
  end,
}
