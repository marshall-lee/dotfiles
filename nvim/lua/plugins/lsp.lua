return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  opts = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    return {
      capabilities = capabilities,
      servers = {},
    }
  end,
  config = function(_, opts)
    for server, server_opts in pairs(opts.servers) do
      server_opts.capabilities = vim.tbl_deep_extend(
        "force",
        {},
        opts.capabilities or {},
        server_opts.capabilities or {}
      )
      vim.lsp.config(server, server_opts)
      vim.lsp.enable(server)
    end
  end,
}
