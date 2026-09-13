local raycast_dark = {
  -- structural
  base = "#1a1a1a", -- background
  mantle = "#1a1a1a", -- no separate "darker than bg" tone in the source theme
  crust = "#000000", -- palette 0
  surface0 = "#1a1a1a", -- bg_alt (colors/ghostty.lua)
  surface1 = "#333333", -- selection-background
  surface2 = "#4c4c4c", -- palette 8 / border
  overlay0 = "#4c4c4c", -- border
  overlay1 = "#4c4c4c", -- border
  overlay2 = "#999999", -- cursor-text / fg_dim
  subtext0 = "#999999", -- cursor-text / fg_dim
  subtext1 = "#cccccc", -- cursor-color
  text = "#ffffff", -- foreground / palette 7 & 15
  -- accents (palette 1-6, and their bright 9-14 variants)
  red = "#ff5360", -- palette 1
  maroon = "#ff5360", -- palette 1
  peach = "#ff6363", -- palette 9 (bright red), the Raycast accent
  yellow = "#ffc531", -- palette 3 / 11
  green = "#59d499", -- palette 2 / 10
  teal = "#52eee5", -- palette 6 / 14 (cyan)
  sky = "#52eee5", -- palette 6 / 14 (cyan)
  sapphire = "#56c2ff", -- palette 4 / 12 (blue)
  blue = "#56c2ff", -- palette 4 / 12 (blue)
  lavender = "#56c2ff", -- avoid purple, reuse blue
  mauve = "#cf2f98", -- palette 5 / 13 (magenta)
  pink = "#cf2f98", -- palette 5 / 13 (magenta)
  flamingo = "#ff6363", -- palette 9 (bright red)
  rosewater = "#ff6363", -- palette 9 (bright red)
}

-- selection-foreground from the theme (#595959) has no Catppuccin role slot,
-- so it's applied directly below instead of going through color_overrides.
local selection_fg = "#595959"

return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      auto_integration = true,
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      color_overrides = {
        mocha = raycast_dark,
      },
      styles = {
        comments = { "italic" },
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      custom_highlights = function(colors)
        return {
          -- UI
          Normal = { fg = colors.text, bg = colors.base },
          NormalFloat = { fg = colors.text, bg = colors.surface0 },
          FloatBorder = { fg = colors.overlay0, bg = colors.surface0 },
          Cursor = { fg = colors.overlay2, bg = colors.subtext1 },
          TermCursor = { fg = colors.overlay2, bg = colors.subtext1 },
          CursorLine = { bg = colors.surface0 },
          CursorLineNr = { fg = colors.yellow, style = { "bold" } },
          LineNr = { fg = colors.overlay0 },
          Visual = { bg = colors.surface1, fg = selection_fg },
          VisualNOS = { bg = colors.surface1, fg = selection_fg },
          Search = { fg = colors.base, bg = colors.yellow },
          IncSearch = { fg = colors.base, bg = colors.blue },
          Pmenu = { fg = colors.text, bg = colors.surface0 },
          PmenuSel = { fg = colors.base, bg = colors.blue },
          StatusLine = { fg = colors.text, bg = colors.surface0 },
          StatusLineNC = { fg = colors.subtext0, bg = colors.surface0 },
          VertSplit = { fg = colors.overlay0 },
          WinSeparator = { fg = colors.overlay0 },
          SignColumn = { bg = colors.base },
          MatchParen = { fg = colors.yellow, style = { "bold" } },
          Directory = { fg = colors.blue },
          NonText = { fg = colors.overlay0 },
          Whitespace = { fg = colors.overlay0 },

          -- Diagnostics
          DiagnosticError = { fg = colors.red },
          DiagnosticWarn = { fg = colors.yellow },
          DiagnosticInfo = { fg = colors.blue },
          DiagnosticHint = { fg = colors.teal },

          -- Diff
          DiffAdd = { fg = colors.green, bg = colors.surface0 },
          DiffChange = { fg = colors.yellow, bg = colors.surface0 },
          DiffDelete = { fg = colors.red, bg = colors.surface0 },
          DiffText = { fg = colors.blue, bg = colors.surface0 },

          -- Syntax
          Comment = { fg = colors.subtext0, style = { "italic" } },
          Constant = { fg = colors.mauve },
          String = { fg = colors.green },
          Character = { fg = colors.green },
          Number = { fg = colors.mauve },
          Boolean = { fg = colors.mauve },
          Identifier = { fg = colors.text },
          Function = { fg = colors.blue },
          Statement = { fg = colors.red },
          Keyword = { fg = colors.red },
          Operator = { fg = colors.teal },
          PreProc = { fg = colors.teal },
          Type = { fg = colors.yellow },
          Special = { fg = colors.teal },
          Underlined = { fg = colors.blue, style = { "underline" } },
          Error = { fg = colors.red, style = { "bold" } },
          Todo = { fg = colors.base, bg = colors.yellow, style = { "bold" } },

          -- Treesitter
          ["@string.escape"] = { fg = colors.teal },
          ["@string.special"] = { fg = colors.teal },
          ["@constant.builtin"] = { fg = colors.mauve, style = { "bold" } },
          ["@constant.macro"] = { fg = colors.mauve },
          ["@variable.builtin"] = { fg = colors.mauve, style = { "italic" } },
          ["@variable.parameter"] = { fg = colors.text, style = { "italic" } },
          ["@variable.member"] = { fg = colors.text },
          ["@function.builtin"] = { fg = colors.blue, style = { "italic" } },
          ["@function.macro"] = { fg = colors.blue },
          ["@constructor"] = { fg = colors.yellow },
          ["@keyword"] = { fg = colors.red },
          ["@keyword.function"] = { fg = colors.red },
          ["@keyword.return"] = { fg = colors.red },
          ["@keyword.operator"] = { fg = colors.teal },
          ["@keyword.import"] = { fg = colors.red },
          ["@type.builtin"] = { fg = colors.yellow, style = { "italic" } },
          ["@type.definition"] = { fg = colors.yellow },
          ["@attribute"] = { fg = colors.teal },
          ["@namespace"] = { fg = colors.yellow },
          ["@symbol"] = { fg = colors.mauve },
          ["@property"] = { fg = colors.text },
          ["@punctuation.delimiter"] = { fg = colors.subtext0 },
          ["@punctuation.bracket"] = { fg = colors.subtext0 },
          ["@punctuation.special"] = { fg = colors.teal },
          ["@tag"] = { fg = colors.red },
          ["@tag.attribute"] = { fg = colors.yellow, style = { "italic" } },
          ["@tag.delimiter"] = { fg = colors.subtext0 },
          ["@label"] = { fg = colors.teal },
          ["@markup.heading"] = { fg = colors.blue, style = { "bold" } },
          ["@markup.strong"] = { style = { "bold" } },
          ["@markup.italic"] = { style = { "italic" } },
          ["@markup.link"] = { fg = colors.teal, style = { "underline" } },
          ["@markup.link.url"] = { fg = colors.green, style = { "underline" } },
          ["@markup.raw"] = { fg = colors.green },
          ["@markup.list"] = { fg = colors.red },
          ["@diff.plus"] = { fg = colors.green },
          ["@diff.minus"] = { fg = colors.red },
          ["@diff.delta"] = { fg = colors.yellow },

          -- LSP semantic tokens
          ["@lsp.mod.readonly"] = { style = { "italic" } },

          -- BufferLine fill (matches ghostty.lua's BufferLineFill)
          BufferLineFill = { bg = colors.base },
        }
      end,
      integrations = {
        cmp = true,
        blink_cmp = true,
        gitsigns = true,
        neotree = true,
        telescope = true,
        which_key = true,
        indent_blankline = { enabled = true },
        treesitter_context = true,
        notify = true,
        mason = true,
        native_lsp = { enabled = true },
        bufferline = true,
        nvimtree = true,
        snacks = { enabled = true },
      },
    },
  },
}
