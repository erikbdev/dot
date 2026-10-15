-- LSP-backed completion/hover/diagnostics for languages marked in Swift
-- strings. Otter reads the Tree-sitter injection regions declared in
-- after/queries/swift/injections.scm and proxies them to the matching LSP.
--
-- Raw Swift strings have variable-length delimiters. Trim them from the
-- injection range using the Swift parser's complete string node.
vim.treesitter.query.add_directive("swift-string-body!", function(match, _, source, predicate, metadata)
  local capture = predicate[2]
  local node = match[capture] and match[capture][1]
  if not node then
    return
  end

  local text = vim.treesitter.get_node_text(node, source)
  if type(text) == "table" then
    text = table.concat(text, "\n")
  end

  local hashes = text:match("^(#+)") or ""
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

return {
  {
    "jmbuhr/otter.nvim",
    ft = "swift",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
    keys = {
      {
        "<leader>co",
        function()
          require("otter").activate()
        end,
        desc = "Activate embedded language support in Swift",
      },
      {
        "<leader>cO",
        function()
          require("otter").deactivate()
        end,
        desc = "Deactivate otter",
      },
    },
  },

  -- Common parsers for marked strings. Other languages work when their
  -- parser and LSP server are installed/configured and Otter supports them.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "javascript", "css", "html" } },
  },

  -- LSP servers otter borrows from — mason auto-installs both since they're
  -- just added under `servers` like any other LazyVim-managed server.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {},
        cssls = {},
        html = {},
      },
    },
  },

  -- Blink requests completions from every client attached to the Swift
  -- buffer. Inside an injected region, keep only Otter's routed results so
  -- SourceKit suggestions do not get mixed in with embedded-language items.
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.lsp = opts.sources.providers.lsp or {}
      opts.sources.providers.lsp.transform_items = function(_, items)
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype ~= "swift" then
          return items
        end

        local ok, keeper = pcall(require, "otter.keeper")
        if not ok or not keeper.rafts[bufnr] then
          return items
        end

        if not keeper.get_current_language_context(bufnr) then
          return items
        end

        local otter_client = ("otter-ls[%d]"):format(bufnr)
        return vim.tbl_filter(function(item)
          return item.client_name == otter_client
        end, items)
      end
      return opts
    end,
  },
}
