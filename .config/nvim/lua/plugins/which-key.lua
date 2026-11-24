return function()
  local which_key = require('which-key')

  which_key.setup({
    delay = 0,
    win = {
      border = 'rounded',
      width = 42,
      height = { min = 4, max = 12 },
      row = math.huge,
      col = math.huge,
      no_overlap = false,
      padding = { 0, 1 },
      title = true,
      wo = { winblend = 0 },
    },
    layout = {
      width = { min = 18, max = 38 },
      spacing = 2,
      align = 'left',
    },
    show_help = false,
    show_keys = false,
  })

  which_key.add({
    { '<leader>b', group = 'Buffers' },
    { '<leader>c', group = 'Code' },
    { '<leader>f', group = 'Find' },
    { '<leader>q', group = 'Quit' },
    { '<leader>s', group = 'Search' },
  })
end
