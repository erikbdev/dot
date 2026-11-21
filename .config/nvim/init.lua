if vim.fn.has('nvim-0.12') == 0 then
  error('This configuration requires Neovim 0.12 or newer')
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.plugins')
vim.cmd.colorscheme('xcodedark')
