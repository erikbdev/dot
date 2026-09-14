-- LSP-backed completions/hover/diagnostics for JavaScript/CSS injected into
-- Swift raw/multi-line string literals (see swift-wav's MainPage.swift,
-- which inlines its client-side JS/CSS this way). Otter reads the
-- Tree-sitter injection regions declared in
-- after/queries/swift/injections.scm and proxies them to whatever LSP
-- client is already attached for that filetype (vtsls / cssls below).
--
-- NOTE: this only finds anything to inject once a `/* js */` or
-- `/* css */` marker comment sits directly before the string literal in
-- the Swift source — the injection query matches on that comment.
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
          require("otter").activate({ "javascript", "css" })
        end,
        desc = "Activate otter (JS/CSS embedded in Swift)",
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

  -- Parsers needed for the injected regions themselves.
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "javascript", "css" } },
  },

  -- LSP servers otter borrows from — mason auto-installs both since they're
  -- just added under `servers` like any other LazyVim-managed server.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {},
        cssls = {},
      },
    },
  },
}
