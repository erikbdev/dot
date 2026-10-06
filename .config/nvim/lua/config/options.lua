-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Show the file name in Ghostty's tab/split title
vim.opt.title = true
vim.opt.titlestring = "%t – nvim"

-- Listen on a per-project socket so `e <file>` (~/.zshrc) in another Ghostty
-- split opens files in this instance instead of starting a second nvim.
local root = vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()
local sock = (vim.env.XDG_RUNTIME_DIR or "/tmp") .. "/nvim-" .. vim.fn.sha256(root):sub(1, 12) .. ".sock"
if vim.uv.fs_stat(sock) then
  local ok, chan = pcall(vim.fn.sockconnect, "pipe", sock)
  if ok then
    vim.fn.chanclose(chan) -- another nvim already owns this project
  else
    os.remove(sock) -- stale socket left by a crashed nvim
  end
end
pcall(vim.fn.serverstart, sock)

-- Use OSC52 so yanks reach the system clipboard through Ghostty even over SSH
-- vim.g.clipboard = vim.g.clipboard
--   or {
--     name = "OSC 52",
--     copy = {
--       ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--       ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--     },
--     paste = {
--       ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--       ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--     },
--   }
