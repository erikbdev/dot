-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

local function terminal_split(command)
  vim.cmd(command)
  vim.cmd("terminal")
  vim.cmd("startinsert")
end

-- Toggle comment, on top of the default gcc/gc.
map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
map("v", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })

-- Navigate between splits
map("n", "<C-h>", "<C-w>h", { desc = "Focus left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right split" })

-- Normal Neovim window splits
map("n", "<C-w>h", "<cmd>leftabove vsplit<cr>", { desc = "Window split left" })
map("n", "<C-w>l", "<cmd>rightbelow vsplit<cr>", { desc = "Window split right" })
map("n", "<C-w>k", "<cmd>leftabove split<cr>", { desc = "Window split up" })
map("n", "<C-w>j", "<cmd>rightbelow split<cr>", { desc = "Window split down" })

-- Neovim terminal splits
map("n", "<C-t>h", function()
  terminal_split("leftabove vsplit")
end, { desc = "Terminal left" })

map("n", "<C-t>j", function()
  terminal_split("rightbelow split")
end, { desc = "Terminal down" })

map("n", "<C-t>k", function()
  terminal_split("leftabove split")
end, { desc = "Terminal up" })

map("n", "<C-t>l", function()
  terminal_split("rightbelow vsplit")
end, { desc = "Terminal right" })

-- Resize splits
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Resize left" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Resize right" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Resize up" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Resize down" })

-- Close
map("n", "<C-w>q", "<cmd>close<cr>", { desc = "Close window" })
map("n", "<C-t>q", "<cmd>close<cr>", { desc = "Close terminal window" })

-- Navigate while inside terminal mode
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Focus left window" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Focus lower window" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Focus upper window" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Focus right window" })
