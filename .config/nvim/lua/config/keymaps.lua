-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Toggle comment, on top of the default gcc/gc.
map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
map("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

-- Terminals live in Ghostty splits, not inside Neovim.
vim.keymap.del("n", "<leader>ft")
vim.keymap.del("n", "<leader>fT")
vim.keymap.del({ "n", "t" }, "<C-/>")
vim.keymap.del({ "n", "t" }, "<C-_>")

-- Tabs live in Ghostty, not inside Neovim.
for _, lhs in ipairs({ "<tab><tab>", "<tab>]", "<tab>[", "<tab>d", "<tab>l", "<tab>f", "<tab>o" }) do
  vim.keymap.del("n", "<leader>" .. lhs)
end
vim.keymap.del("n", "<leader>uA")
