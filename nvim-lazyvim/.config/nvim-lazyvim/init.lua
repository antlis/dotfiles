-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("tgpt").setup()

-- Custom gf handling for file: URLs with spaces
vim.api.nvim_set_keymap("n", "gf", ":lua CustomGF()<CR>", { noremap = true, silent = true })
function CustomGF()
  local current_file = vim.fn.expand("<cfile>")
  if current_file:match("^file:") then
    -- Remove 'file:' prefix and decode %20 to spaces
    local path = current_file:gsub("^file:", ""):gsub("%%20", " ")
    path = vim.fn.fnameescape(path)
    vim.cmd("edit " .. path)
  else
    -- Default behavior for non-URLs
    vim.cmd("edit " .. vim.fn.expand("<cfile>"))
  end
end
