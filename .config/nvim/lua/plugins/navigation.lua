return function()
  local fzf = require('fzf-lua')
  fzf.setup({
    'default-title',
    winopts = { split = 'belowright new' },
    previewer = false,
    files = { hidden = true, no_ignore = false },
    grep = { hidden = true, no_ignore = false },
  })

  local map = vim.keymap.set
  map('n', '<leader>ff', fzf.files, { desc = 'Find files' })
  map('n', '<leader>fr', fzf.oldfiles, { desc = 'Recent files' })
  map('n', '<leader>fb', fzf.buffers, { desc = 'Open buffers' })
  map('n', '<leader>sd', fzf.diagnostics_document, { desc = 'Buffer diagnostics' })
  map('n', '<leader>sD', fzf.diagnostics_workspace, { desc = 'Workspace diagnostics' })
end
