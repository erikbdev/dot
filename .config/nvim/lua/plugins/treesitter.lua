return function()
  local languages = {
    'swift',
    'javascript',
    'typescript',
    'tsx',
    'jsx',
    'ecma',
    'html_tags',
    'vue',
    'lua',
    'html',
    'css',
    'json',
  }

  require('nvim-treesitter').install(languages)

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('config.treesitter', { clear = true }),
    pattern = {
      'swift',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'vue',
      'lua',
      'html',
      'css',
      'json',
    },
    callback = function(event)
      local language = vim.treesitter.language.get_lang(vim.bo[event.buf].filetype)
      if language then
        pcall(vim.treesitter.start, event.buf, language)
      end
    end,
  })
end
