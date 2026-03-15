-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- require("tgpt").setup()

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

-- Load .zsh_private from .dotfiles
local home = os.getenv("HOME")
local dotfiles_path = home .. "/.dotfiles/zsh/.zsh_private"

local exists = vim.fn.filereadable(dotfiles_path)
if exists == 1 then
  local lines = vim.fn.readfile(dotfiles_path)

  for _, line in ipairs(lines) do
    if line:find("export ") then
      local key_start = line:find("export ") + 7
      local key_end = line:find("=", key_start) - 1
      local key = line:sub(key_start, key_end)

      local value_start = line:find('"', key_end) + 1
      local value_end = line:find('"', value_start) - 1
      local value = line:sub(value_start, value_end)

      if key and value then
        vim.env[key] = value
      end
    end
  end
end
