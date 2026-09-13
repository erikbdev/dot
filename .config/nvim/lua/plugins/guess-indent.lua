return {
  "NMAC427/guess-indent.nvim",
  -- must load eagerly: its own BufReadPost/BufNewFile autocmds need to exist
  -- before Neovim reads files passed on the command line, and lazy.nvim's
  -- event-based lazy-loading race loses that race for `nvim somefile`.
  lazy = false,
  opts = {},
}
