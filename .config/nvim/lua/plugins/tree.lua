return function()
  require('nvim-tree').setup({
    sync_root_with_cwd = false,
    respect_buf_cwd = true,
    update_focused_file = {
      enable = true,
      update_root = true,
    },
    view = {
      side = 'left',
      width = 32,
    },
    actions = {
      open_file = {
        quit_on_open = false,
      },
    },
  })

  vim.keymap.set('n', '<leader>e', function()
    local file = vim.api.nvim_buf_get_name(0)
    local path = file ~= '' and vim.fn.fnamemodify(file, ':p:h') or vim.fn.getcwd()

    require('nvim-tree.api').tree.toggle({
      path = path,
      find_file = file ~= '',
      update_root = true,
    })
  end, { desc = 'Toggle file tree' })
end
