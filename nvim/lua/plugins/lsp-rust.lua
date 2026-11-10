local cargo_target = vim.env.CARGO_BUILD_TARGET

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            cargo = vim.tbl_extend("force",
              { allFeatures = true },
              cargo_target and { target = cargo_target } or {}
            ),
          },
        },
      },
    },
  },
}
