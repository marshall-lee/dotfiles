return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
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

    telescope.setup({
      pickers = {
        buffers = {
          theme = "ivy",
        },
        live_grep = {
          theme = "ivy",
        },
        find_files = {
          theme = "ivy",
        },
      },
      extensions = {
        file_browser = {
          theme = "ivy",
          previewer = false,
          hijack_netrw = true,
        },
      },
      defaults = {
        mappings = {
          n = {
            ["<leader>p"] = require("telescope.actions.layout").toggle_preview,
          },
        },
      },
    })

    telescope.load_extension('fzf')
    telescope.load_extension('file_browser')

    local builtin = require("telescope.builtin")
    local file_browser = require("telescope").extensions.file_browser
    vim.keymap.set('n', '<leader>ff', function()
      builtin.find_files({
        prompt_title = "Find Files",
        cwd = vim.fn.getcwd(),
        preview = false,
      })
    end, { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fF', function()
      file_browser.file_browser({
        prompt_title = "Project File Browser",
        path = "%:p:h",
        select_buffer = true,
      })
    end, { desc = "Telescope find files in buffer's directory" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = 'Telescope recent files' })
    vim.keymap.set("n", "<leader>fR", function() builtin.oldfiles({ initial_mode = "normal" }) end, { desc = 'Telescope recent files (normal mode)' })
    vim.keymap.set('n', '<leader>fg', function()
      builtin.live_grep({ debounce = 150 })
    end, { desc = 'Telescope live grep' })
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
