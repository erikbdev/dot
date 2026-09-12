-- Neovim colorscheme generated from ~/.config/ghostty/auto/theme.ghostty (Raycast Dark palette).
-- Keep this file's hex values in sync by hand whenever the Ghostty theme changes.

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "ghostty"

local c = {
  black = "#000000",
  bg = "#1a1a1a",
  bg_alt = "#242424",
  selection = "#333333",
  selection_fg = "#595959",
  border = "#4c4c4c",
  fg = "#ffffff",
  fg_dim = "#999999",
  cursor = "#cccccc",
  cursor_text = "#999999",
  red = "#ff5360",
  red_bright = "#ff6363",
  green = "#59d499",
  yellow = "#ffc531",
  blue = "#56c2ff",
  magenta = "#cf2f98",
  cyan = "#52eee5",
}

-- Faithful ANSI 0-15 mapping from ~/.config/ghostty themes/Raycast Dark, for
-- Neovim's :terminal emulator (this is otherwise never styled by a colorscheme).
vim.g.terminal_color_0 = c.black
vim.g.terminal_color_1 = c.red
vim.g.terminal_color_2 = c.green
vim.g.terminal_color_3 = c.yellow
vim.g.terminal_color_4 = c.blue
vim.g.terminal_color_5 = c.magenta
vim.g.terminal_color_6 = c.cyan
vim.g.terminal_color_7 = c.fg
vim.g.terminal_color_8 = c.border
vim.g.terminal_color_9 = c.red_bright
vim.g.terminal_color_10 = c.green
vim.g.terminal_color_11 = c.yellow
vim.g.terminal_color_12 = c.blue
vim.g.terminal_color_13 = c.magenta
vim.g.terminal_color_14 = c.cyan
vim.g.terminal_color_15 = c.fg

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- UI
hi("Normal", { fg = c.fg, bg = c.bg })
hi("NormalFloat", { fg = c.fg, bg = c.bg_alt })
hi("FloatBorder", { fg = c.border, bg = c.bg_alt })
hi("Cursor", { fg = c.cursor_text, bg = c.cursor })
hi("TermCursor", { fg = c.cursor_text, bg = c.cursor })
hi("CursorLine", { bg = c.bg_alt })
hi("CursorLineNr", { fg = c.yellow, bold = true })
hi("LineNr", { fg = c.border })
hi("Visual", { bg = c.selection, fg = c.selection_fg })
hi("VisualNOS", { bg = c.selection, fg = c.selection_fg })
hi("Search", { fg = c.bg, bg = c.yellow })
hi("IncSearch", { fg = c.bg, bg = c.blue })
hi("Pmenu", { fg = c.fg, bg = c.bg_alt })
hi("PmenuSel", { fg = c.bg, bg = c.blue })
hi("StatusLine", { fg = c.fg, bg = c.bg_alt })
hi("StatusLineNC", { fg = c.fg_dim, bg = c.bg_alt })
hi("VertSplit", { fg = c.border })
hi("WinSeparator", { fg = c.border })
hi("SignColumn", { bg = c.bg })
hi("MatchParen", { fg = c.yellow, bold = true })
hi("Directory", { fg = c.blue })
hi("NonText", { fg = c.border })
hi("Whitespace", { fg = c.border })

-- Diagnostics
hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn", { fg = c.yellow })
hi("DiagnosticInfo", { fg = c.blue })
hi("DiagnosticHint", { fg = c.cyan })

-- Diff
hi("DiffAdd", { fg = c.green, bg = c.bg_alt })
hi("DiffChange", { fg = c.yellow, bg = c.bg_alt })
hi("DiffDelete", { fg = c.red, bg = c.bg_alt })
hi("DiffText", { fg = c.blue, bg = c.bg_alt })

-- Syntax
hi("Comment", { fg = c.fg_dim, italic = true })
hi("Constant", { fg = c.magenta })
hi("String", { fg = c.green })
hi("Character", { fg = c.green })
hi("Number", { fg = c.magenta })
hi("Boolean", { fg = c.magenta })
hi("Identifier", { fg = c.fg })
hi("Function", { fg = c.blue })
hi("Statement", { fg = c.red })
hi("Keyword", { fg = c.red })
hi("Operator", { fg = c.cyan })
hi("PreProc", { fg = c.cyan })
hi("Type", { fg = c.yellow })
hi("Special", { fg = c.cyan })
hi("Underlined", { fg = c.blue, underline = true })
hi("Error", { fg = c.red, bold = true })
hi("Todo", { fg = c.bg, bg = c.yellow, bold = true })

-- Treesitter
hi("@comment", { link = "Comment" })
hi("@string", { link = "String" })
hi("@string.escape", { fg = c.cyan })
hi("@string.special", { fg = c.cyan })
hi("@character", { link = "Character" })
hi("@number", { link = "Number" })
hi("@boolean", { link = "Boolean" })
hi("@float", { link = "Number" })
hi("@constant", { link = "Constant" })
hi("@constant.builtin", { fg = c.magenta, bold = true })
hi("@constant.macro", { fg = c.magenta })
hi("@variable", { fg = c.fg })
hi("@variable.builtin", { fg = c.magenta, italic = true })
hi("@variable.parameter", { fg = c.fg, italic = true })
hi("@variable.member", { fg = c.fg })
hi("@property", { fg = c.fg })
hi("@field", { fg = c.fg })
hi("@function", { link = "Function" })
hi("@function.call", { link = "Function" })
hi("@function.builtin", { fg = c.blue, italic = true })
hi("@function.macro", { fg = c.blue })
hi("@method", { link = "Function" })
hi("@method.call", { link = "Function" })
hi("@constructor", { fg = c.yellow })
hi("@keyword", { link = "Keyword" })
hi("@keyword.function", { fg = c.red })
hi("@keyword.return", { fg = c.red })
hi("@keyword.operator", { fg = c.cyan })
hi("@keyword.import", { fg = c.red })
hi("@conditional", { link = "Keyword" })
hi("@repeat", { link = "Keyword" })
hi("@exception", { link = "Keyword" })
hi("@type", { link = "Type" })
hi("@type.builtin", { fg = c.yellow, italic = true })
hi("@type.definition", { fg = c.yellow })
hi("@attribute", { fg = c.cyan })
hi("@namespace", { fg = c.yellow })
hi("@symbol", { fg = c.magenta })
hi("@operator", { link = "Operator" })
hi("@punctuation.delimiter", { fg = c.fg_dim })
hi("@punctuation.bracket", { fg = c.fg_dim })
hi("@punctuation.special", { fg = c.cyan })
hi("@tag", { fg = c.red })
hi("@tag.attribute", { fg = c.yellow, italic = true })
hi("@tag.delimiter", { fg = c.fg_dim })
hi("@label", { fg = c.cyan })
hi("@markup.heading", { fg = c.blue, bold = true })
hi("@markup.strong", { bold = true })
hi("@markup.italic", { italic = true })
hi("@markup.link", { fg = c.cyan, underline = true })
hi("@markup.link.url", { fg = c.green, underline = true })
hi("@markup.raw", { fg = c.green })
hi("@markup.list", { fg = c.red })
hi("@diff.plus", { fg = c.green })
hi("@diff.minus", { fg = c.red })
hi("@diff.delta", { fg = c.yellow })

-- LSP semantic tokens (fall back to Treesitter groups)
hi("@lsp.type.class", { link = "@type" })
hi("@lsp.type.decorator", { link = "@attribute" })
hi("@lsp.type.enum", { link = "@type" })
hi("@lsp.type.enumMember", { link = "@constant" })
hi("@lsp.type.function", { link = "@function" })
hi("@lsp.type.interface", { link = "@type" })
hi("@lsp.type.macro", { link = "@function.macro" })
hi("@lsp.type.method", { link = "@method" })
hi("@lsp.type.namespace", { link = "@namespace" })
hi("@lsp.type.parameter", { link = "@variable.parameter" })
hi("@lsp.type.property", { link = "@property" })
hi("@lsp.type.struct", { link = "@type" })
hi("@lsp.type.type", { link = "@type" })
hi("@lsp.type.variable", { link = "@variable" })
hi("@lsp.mod.readonly", { italic = true })

-- LazyVim / plugin UI
hi("TelescopeNormal", { fg = c.fg, bg = c.bg_alt })
hi("TelescopeBorder", { fg = c.border, bg = c.bg_alt })
hi("TelescopePromptNormal", { fg = c.fg, bg = c.bg_alt })
hi("TelescopePromptBorder", { fg = c.border, bg = c.bg_alt })
hi("TelescopeSelection", { bg = c.selection })
hi("TelescopeMatching", { fg = c.yellow, bold = true })
hi("WhichKeyFloat", { bg = c.bg_alt })
hi("WhichKey", { fg = c.blue })
hi("WhichKeyGroup", { fg = c.cyan })
hi("WhichKeyDesc", { fg = c.fg })
hi("NeoTreeNormal", { fg = c.fg, bg = c.bg })
hi("NeoTreeNormalNC", { fg = c.fg, bg = c.bg })
hi("NeoTreeDirectoryIcon", { fg = c.blue })
hi("NeoTreeDirectoryName", { fg = c.blue })
hi("NeoTreeRootName", { fg = c.yellow, bold = true })
hi("NeoTreeGitAdded", { fg = c.green })
hi("NeoTreeGitModified", { fg = c.yellow })
hi("NeoTreeGitDeleted", { fg = c.red })
hi("GitSignsAdd", { fg = c.green })
hi("GitSignsChange", { fg = c.yellow })
hi("GitSignsDelete", { fg = c.red })
hi("IblIndent", { fg = c.border })
hi("IblScope", { fg = c.fg_dim })
hi("TreesitterContext", { bg = c.bg_alt })
hi("TreesitterContextLineNumber", { fg = c.fg_dim })
hi("CmpItemAbbrMatch", { fg = c.yellow, bold = true })
hi("CmpItemKindFunction", { fg = c.blue })
hi("CmpItemKindVariable", { fg = c.fg })
hi("CmpItemKindKeyword", { fg = c.red })
hi("BlinkCmpMenuBorder", { fg = c.border, bg = c.bg_alt })
hi("BlinkCmpLabelMatch", { fg = c.yellow, bold = true })
hi("BufferLineFill", { bg = c.bg })
hi("NotifyERRORBorder", { fg = c.red })
hi("NotifyWARNBorder", { fg = c.yellow })
hi("NotifyINFOBorder", { fg = c.blue })
