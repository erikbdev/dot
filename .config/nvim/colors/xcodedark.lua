-- XcodeDark syntax palette with the Raycast Dark editor background.
vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end
-- vim.o.background = 'dark'
vim.g.colors_name = 'xcodedark'

-- local bg = '#1a1a1a'
local bg = ''
local surface = '#252526'
local line = '#2d2d30'
local fg = '#ffffff'
local muted = '#858585'
local dim = '#9d9d9d'
local comment = '#6c7986'
local keyword = '#ff7ab2'
local string = '#ff8170'
local number = '#d9c97c'
local function_color = '#67b7a4'
local variable = '#67b7a4'
local constant = '#4eb0cc'
local type = '#6bdfff'
local property = '#67b7a4'
local parameter = '#d2a8ff'
local preprocessor = '#ff7ab2'
local attribute = '#fd8f3f'
local operator = '#ffffff'
local punctuation = '#ffffff'
local url = '#5482ff'
local error = '#f14c4c'
local warning = '#f1c232'
local info = '#0099ff'
local hint = '#4eb0cc'
local border = '#3e3e42'

local highlights = {
  Normal = { fg = fg, bg = bg },
  NormalNC = { fg = fg, bg = bg },
  NormalFloat = { fg = fg, bg = surface },
  FloatBorder = { fg = border, bg = surface },
  FloatTitle = { fg = function_color, bg = surface, bold = true },
  FloatFooter = { fg = muted, bg = surface },
  WinSeparator = { fg = border, bg = bg },

  Cursor = { fg = bg, bg = '#ff5257' },
  CursorLine = { bg = line },
  CursorColumn = { bg = line },
  CursorLineNr = { fg = keyword, bold = true },
  LineNr = { fg = muted, bg = bg },
  SignColumn = { bg = bg },
  FoldColumn = { fg = muted, bg = bg },
  ColorColumn = { bg = line },
  Visual = { bg = '#636f83' },
  Search = { fg = '#ffcc02', bg = '#613315' },
  IncSearch = { fg = fg, bg = '#094771' },
  CurSearch = { fg = '#ffcc02', bg = '#613315' },
  Pmenu = { fg = '#cccccc', bg = '#454167' },
  PmenuSel = { fg = fg, bg = keyword },
  PmenuSbar = { bg = border },
  PmenuThumb = { bg = '#686868' },
  StatusLine = { fg = '#cccccc', bg = line },
  StatusLineNC = { fg = muted, bg = line },
  TabLine = { fg = muted, bg = line },
  TabLineFill = { bg = line },
  TabLineSel = { fg = fg, bg = bg, bold = true },
  NonText = { fg = comment },
  EndOfBuffer = { fg = bg },
  Directory = { fg = function_color },
  MatchParen = { fg = info, bold = true },
  Folded = { fg = dim, bg = line },
  ErrorMsg = { fg = error },
  WarningMsg = { fg = warning },
  MoreMsg = { fg = info },
  Question = { fg = info },

  Comment = { fg = comment },
  Constant = { fg = constant },
  String = { fg = string },
  Character = { fg = string },
  Number = { fg = number },
  Boolean = { fg = keyword },
  Float = { fg = number },
  Identifier = { fg = fg },
  Function = { fg = function_color },
  Statement = { fg = keyword },
  Conditional = { fg = keyword },
  Repeat = { fg = keyword },
  Label = { fg = keyword },
  Operator = { fg = operator },
  Keyword = { fg = keyword },
  Exception = { fg = keyword },
  PreProc = { fg = preprocessor },
  Include = { fg = preprocessor },
  Define = { fg = preprocessor },
  Macro = { fg = attribute },
  Type = { fg = type },
  StorageClass = { fg = keyword },
  Structure = { fg = type },
  Typedef = { fg = type },
  Special = { fg = attribute },
  SpecialChar = { fg = string },
  Tag = { fg = type },
  Delimiter = { fg = punctuation },
  Underlined = { fg = url, underline = true },
  Error = { fg = error, bold = true },
  Todo = { fg = number, bold = true },

  DiagnosticError = { fg = error },
  DiagnosticWarn = { fg = warning },
  DiagnosticInfo = { fg = info },
  DiagnosticHint = { fg = hint },
  DiagnosticSignError = { fg = error, bg = bg },
  DiagnosticSignWarn = { fg = warning, bg = bg },
  DiagnosticSignInfo = { fg = info, bg = bg },
  DiagnosticSignHint = { fg = hint, bg = bg },
  DiagnosticUnderlineError = { undercurl = true, sp = error },
  DiagnosticUnderlineWarn = { undercurl = true, sp = warning },
  DiagnosticUnderlineInfo = { undercurl = true, sp = info },
  DiagnosticUnderlineHint = { undercurl = true, sp = hint },

  ['@comment'] = { fg = comment },
  ['@comment.documentation'] = { fg = comment },
  ['@comment.documentation.keyword'] = { fg = number },
  ['@variable'] = { fg = variable },
  ['@variable.builtin'] = { fg = keyword },
  ['@variable.parameter'] = { fg = parameter },
  ['@variable.member'] = { fg = property },
  ['@constant'] = { fg = constant },
  ['@constant.builtin'] = { fg = constant },
  ['@constant.macro'] = { fg = constant },
  ['@string'] = { fg = string },
  ['@string.escape'] = { fg = string },
  ['@character'] = { fg = string },
  ['@number'] = { fg = number },
  ['@boolean'] = { fg = keyword },
  ['@type'] = { fg = type },
  ['@type.builtin'] = { fg = type },
  ['@attribute'] = { fg = attribute },
  ['@property'] = { fg = property },
  ['@module'] = { fg = type },
  ['@function'] = { fg = function_color },
  ['@function.call'] = { fg = function_color },
  ['@function.method'] = { fg = function_color },
  ['@function.method.call'] = { fg = function_color },
  ['@function.builtin'] = { fg = function_color },
  ['@function.macro'] = { fg = attribute },
  ['@method'] = { fg = function_color },
  ['@method.call'] = { fg = function_color },
  ['@constructor'] = { fg = type },
  ['@keyword'] = { fg = keyword },
  ['@keyword.function'] = { fg = keyword },
  ['@keyword.type'] = { fg = keyword },
  ['@keyword.modifier'] = { fg = keyword },
  ['@keyword.import'] = { fg = preprocessor },
  ['@keyword.directive'] = { fg = preprocessor },
  ['@keyword.return'] = { fg = keyword },
  ['@keyword.conditional'] = { fg = keyword },
  ['@keyword.conditional.ternary'] = { fg = keyword },
  ['@keyword.repeat'] = { fg = keyword },
  ['@keyword.exception'] = { fg = keyword },
  ['@keyword.coroutine'] = { fg = keyword },
  ['@keyword.operator'] = { fg = keyword },
  ['@operator'] = { fg = operator },
  ['@punctuation.delimiter'] = { fg = punctuation },
  ['@punctuation.bracket'] = { fg = punctuation },
  ['@punctuation.special'] = { fg = punctuation },
  ['@tag'] = { fg = type },
  ['@tag.attribute'] = { fg = attribute },
  ['@markup.raw'] = { fg = string },
  ['@markup.link.url'] = { fg = url, underline = true },

  ['@lsp.type.class'] = { fg = type },
  ['@lsp.type.enum'] = { fg = type },
  ['@lsp.type.enumMember'] = { fg = constant },
  ['@lsp.type.function'] = { fg = function_color },
  ['@lsp.type.interface'] = { fg = type },
  ['@lsp.type.keyword'] = { fg = keyword },
  ['@lsp.typemod.keyword.defaultLibrary'] = { fg = keyword },
  ['@lsp.type.macro'] = { fg = attribute },
  ['@lsp.type.decorator'] = { fg = attribute },
  ['@lsp.type.method'] = { fg = function_color },
  ['@lsp.type.namespace'] = { fg = type },
  ['@lsp.type.parameter'] = { fg = parameter },
  ['@lsp.type.property'] = { fg = property },
  ['@lsp.type.struct'] = { fg = type },
  ['@lsp.type.type'] = { fg = type },
  ['@lsp.type.typeParameter'] = { fg = type },
  ['@lsp.type.variable'] = { fg = variable },
  ['@lsp.mod.readonly'] = { fg = constant },
  ['@lsp.typemod.variable.readonly'] = { fg = constant },
  ['@lsp.mod.static'] = { fg = constant },
  ['@lsp.mod.deprecated'] = { fg = dim, strikethrough = true },
}

for group, style in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, style)
end

