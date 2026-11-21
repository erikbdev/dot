return function()
  require('conform').setup({
    formatters_by_ft = {
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      vue = { 'prettier' },
      html = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      markdown = { 'prettier' },
      lua = { 'stylua' },
    },
  })

  vim.keymap.set({ 'n', 'x' }, '<leader>cf', function()
    require('conform').format({ async = true, lsp_format = 'fallback' })
  end, { desc = 'Format buffer or selection' })
end
