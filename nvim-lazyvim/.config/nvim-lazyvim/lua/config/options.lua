-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.autoformat = false
vim.g.autoread = true
vim.g.ignorecase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.spelllang = { "en", "ru" }

-- Auto-install spell files if missing
local spell_dir = vim.fn.stdpath("config") .. "/spell"
if vim.fn.isdirectory(spell_dir) == 0 then
  vim.fn.mkdir(spell_dir, "p")
end
if vim.fn.filereadable(spell_dir .. "/ru.utf-8.spl") == 0 then
  vim.fn.system({
    "curl", "-fLo", spell_dir .. "/ru.utf-8.spl",
    "https://raw.githubusercontent.com/vim/vim/master/runtime/spell/russian/russian.utf-8.spl",
  })
end
