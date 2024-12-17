-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "-", ":Neotree toggle <cr>", { desc = "Open File Tree" })
-- vim.keymap.set("n", "<C-p>", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<C-p>", ":FzfLua files<CR>", { desc = "Find files" })
