return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        hidden = true,
        ignored = true,
      },
      picker = {
        -- No tabpages: drop the "open in new tab" action.
        win = {
          input = { keys = { ["<c-t>"] = false } },
          list = { keys = { ["<c-t>"] = false } },
        },
        sources = {
          files = { hidden = true, ignored = true },
          explorer = { hidden = true, ignored = true, layout = { layout = { position = "right" } } },
        },
      },
    },
  },
}
