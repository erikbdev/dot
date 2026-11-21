-- Trim Swift string delimiters from embedded-language injection ranges.
vim.treesitter.query.add_directive('swift-string-body!', function(match, _, source, predicate, metadata)
  local capture = predicate[2]
  local node = match[capture] and match[capture][1]
  if not node then
    return
  end

  local text = vim.treesitter.get_node_text(node, source)
  if type(text) == 'table' then
    text = table.concat(text, '\n')
  end

  local hashes = text:match('^(#+)') or ''
  local quote_start = #hashes + 1
  local quote_count = text:sub(quote_start, quote_start + 2) == '"""' and 3 or 1
  local opening = hashes .. string.rep('"', quote_count)
  local closing = string.rep('"', quote_count) .. hashes
  if text:sub(1, #opening) ~= opening then
    return
  end

  local trim_end = text:sub(-#closing) == closing and #closing or 0
  local start_row, start_col, end_row, end_col = node:range()
  metadata[capture] = metadata[capture] or {}
  metadata[capture].range = { start_row, start_col + #opening, end_row, end_col - trim_end }
end, { force = true })

return function()
  require('otter').setup({})

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('config.otter.keys', { clear = true }),
    pattern = 'swift',
    callback = function(event)
      vim.keymap.set('n', '<leader>co', function()
        require('otter').activate()
      end, { buffer = event.buf, desc = 'Activate embedded language support' })
      vim.keymap.set('n', '<leader>cO', function()
        require('otter').deactivate()
      end, { buffer = event.buf, desc = 'Deactivate Otter' })
    end,
  })

  -- Restrict native LSP completion to Otter while the cursor is inside an
  -- injected region, then restore normal language-server completion outside it.
  local completion_enabled = {}
  local function sync_completion(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= 'swift' then
      return
    end

    local ok, keeper = pcall(require, 'otter.keeper')
    if not ok then
      return
    end

    local in_otter = keeper.rafts[bufnr] ~= nil and keeper.get_current_language_context(bufnr) ~= nil
    local otter_client_name = ('otter-ls[%d]'):format(bufnr)
    local enabled = completion_enabled[bufnr] or {}
    local attached = {}

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
      attached[client.id] = true
      local is_otter = client.name == otter_client_name
      local should_enable = (in_otter and is_otter) or (not in_otter and not is_otter)
      if enabled[client.id] ~= should_enable then
        vim.lsp.completion.enable(should_enable, client.id, bufnr, should_enable and { autotrigger = true } or nil)
        enabled[client.id] = should_enable
      end
    end

    for client_id in pairs(enabled) do
      if not attached[client_id] then
        enabled[client_id] = nil
      end
    end
    completion_enabled[bufnr] = enabled
  end

  local group = vim.api.nvim_create_augroup('config.otter.completion', { clear = true })
  vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI', 'TextChangedI' }, {
    group = group,
    callback = function(event)
      sync_completion(event.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ 'LspAttach', 'LspDetach' }, {
    group = group,
    callback = function(event)
      vim.schedule(function()
        sync_completion(event.buf)
      end)
    end,
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group,
    callback = function(event)
      completion_enabled[event.buf] = nil
    end,
  })
end
