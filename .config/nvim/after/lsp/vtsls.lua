-- Vue's TypeScript plugin is installed alongside its language server.
-- Resolve relative to the executable so no npm subprocess runs on startup.
local executable = vim.fn.exepath('vue-language-server')
local module_root = executable ~= ''
    and vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.uv.fs_realpath(executable) or executable)))
  or ''
-- Vue executable: node_modules/@vue/language-server/bin/vue-language-server.js
local vue_plugin = vim.fs.joinpath(module_root, 'typescript-plugin')

return {
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = vue_plugin,
            languages = { 'vue' },
            configNamespace = 'typescript',
          },
        },
      },
    },
  },
}
