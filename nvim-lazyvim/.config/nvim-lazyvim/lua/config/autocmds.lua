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

-- Set border colors immediately on startup
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#195466", bg = "#11151c" })
vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = "#195466", bg = "#11151c" })
vim.api.nvim_set_hl(0, "NeoTreeBorder", { fg = "#195466", bg = "#11151c" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#195466", bg = "#11151c" })
vim.api.nvim_set_hl(0, "NeoTreeVertSplit", { fg = "#195466", bg = "#11151c" })

-- Also ensure it persists after colorscheme loads
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#195466", bg = "#11151c" })
    vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = "#195466", bg = "#11151c" })
    vim.api.nvim_set_hl(0, "NeoTreeBorder", { fg = "#195466", bg = "#11151c" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#195466", bg = "#11151c" })
    vim.api.nvim_set_hl(0, "NeoTreeVertSplit", { fg = "#195466", bg = "#11151c" })
  end,
})
