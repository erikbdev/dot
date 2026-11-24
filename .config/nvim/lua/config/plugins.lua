vim.pack.add({
  { src = 'https://github.com/ibhagwan/fzf-lua', version = 'main' },
  { src = 'https://github.com/stevearc/conform.nvim', version = 'master' },
  { src = 'https://github.com/neovim/nvim-lspconfig', version = 'master' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua', version = 'master' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/folke/which-key.nvim', version = 'main' },
  { src = 'https://github.com/NMAC427/guess-indent.nvim', version = 'main' },
  { src = 'https://github.com/jmbuhr/otter.nvim', version = 'main' },
}, { confirm = false })

require('plugins.navigation')()
require('plugins.tree')()
require('plugins.which-key')()
require('plugins.formatting')()
require('plugins.lsp')()
require('plugins.guess-indent')()
require('plugins.oxfmt')()
require('plugins.otter')()
require('plugins.treesitter')()
