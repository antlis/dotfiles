-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- optional: command to show full path of current buffer
vim.api.nvim_create_user_command("FullFileCopy", function()
  local path = vim.fn.expand("%:p")
  if path == "" then path = "[No File Name]" end
  vim.fn.setreg("+", path)  -- copy to clipboard (+ register)
  print("Full path copied to clipboard: " .. path)
end, {})
