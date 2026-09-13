-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle comment with Ctrl+/, on top of the default gcc/gc.
-- Most terminals (including ones without a proper key protocol) send <C-/>
-- as <C-_>, so both are mapped to be safe.
local function map_toggle_comment(lhs)
  vim.keymap.set("n", lhs, "gcc", { remap = true, desc = "Toggle comment line" })
  vim.keymap.set("v", lhs, "gc", { remap = true, desc = "Toggle comment" })
end

map_toggle_comment("<C-/>")
map_toggle_comment("<C-_>")
