return function()
  local mason_bin = vim.fn.expand('~/.local/share/nvim/mason/bin')
  if vim.fn.isdirectory(mason_bin) == 1 then
    vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
  end

  vim.diagnostic.config({
    virtual_text = true,
    underline = true,
    severity_sort = true,
    update_in_insert = false,
    float = { border = 'rounded', source = true },
    signs = { text = { [1] = 'E', [2] = 'W', [3] = 'I', [4] = 'H' } },
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('config.lsp', { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      local provider = client and client.server_capabilities.completionProvider
      if provider then
        local triggers = provider.triggerCharacters or {}
        provider.triggerCharacters = triggers
        local seen = {}
        for _, char in ipairs(triggers) do
          seen[char] = true
        end
        for char in ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'):gmatch('.') do
          if not seen[char] then
            table.insert(triggers, char)
          end
        end
      end

      vim.lsp.completion.enable(true, event.data.client_id, event.buf, {
        autotrigger = true,
      })

      local function map(key, action, desc)
        vim.keymap.set('n', key, action, { buffer = event.buf, desc = desc })
      end
      map('gd', vim.lsp.buf.definition, 'Go to definition')
      map('gr', vim.lsp.buf.references, 'Find references')
      map('gI', vim.lsp.buf.implementation, 'Go to implementation')
      map('gy', vim.lsp.buf.type_definition, 'Go to type definition')
      map('K', vim.lsp.buf.hover, 'Hover documentation')
      map('<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
      map('<leader>ca', vim.lsp.buf.code_action, 'Code actions')
      map('<leader>ss', vim.lsp.buf.document_symbol, 'Document symbols')
    end,
  })

  -- Servers are external tools, deliberately installed separately from plugins.
  local servers = {
    sourcekit = 'sourcekit-lsp',
    vtsls = 'vtsls',
    lua_ls = 'lua-language-server',
    html = 'vscode-html-language-server',
    cssls = 'vscode-css-language-server',
    jsonls = 'vscode-json-language-server',
  }
  -- Vue needs both servers; avoid starting it when TypeScript is unavailable.
  if vim.fn.executable('vtsls') == 1 then
    servers.vue_ls = 'vue-language-server'
  end
  for server, executable in pairs(servers) do
    if vim.fn.executable(executable) == 1 then
      vim.lsp.enable(server)
    end
  end
end
