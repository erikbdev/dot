return {
  {
    "folke/snacks.nvim",
    keys = {
      { "C-t", false, mode = "n", "t", "i" },
    },
    opts = {
      explorer = {
        hidden = true,
        ignored = true,
      },
      picker = {
        -- No tabpages: drop the "open in new tab" action.
        win = {
          input = { keys = { ["<C-t>"] = false } },
          list = { keys = { ["<C-t>"] = false } },
        },
        sources = {
          files = { hidden = true, ignored = true },
          explorer = { hidden = true, ignored = true, layout = { layout = { position = "right" } } },
        },
      },
    },
  },
}
