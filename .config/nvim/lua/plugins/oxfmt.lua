return {
  -- LSP Server Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        oxfmt = {
          enabled = true,
          -- Additional settings can be added here
        },
      },
    },
  },
}
