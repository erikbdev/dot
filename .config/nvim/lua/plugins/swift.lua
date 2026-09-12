return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          -- sourcekit-lsp only emits a flat "identifier" semantic token type for
          -- types/variables/members/parameters, which has no highlight mapping and
          -- overrides Treesitter's much richer Swift captures. Disable semantic
          -- tokens so Treesitter highlighting (colors/ghostty.lua) is used instead.
          on_attach = function(client, _)
            client.server_capabilities.semanticTokensProvider = nil
          end,
        },
      },
    },
  },
}
