return function()
  -- nvim-lspconfig supplies the server config, including local project binaries.
  vim.lsp.enable('oxfmt')
end
