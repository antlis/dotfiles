--
-- general
lvim.log.level = "warn"
lvim.colorscheme = "lunar"
-- lvim.colorscheme = "gotham"
-- lvim.colorscheme = "dracula"
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false
--
-- TODO: User Config for predefined plugins
-- After changing plugin config exit and reopen LunarVim, Run :PackerInstall :PackerCompile
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false
lvim.builtin.nvimtree.setup.view.side = "right"

lvim.textwidth=80

-- if you don't want all the parsers change this to a table of the ones you want
lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "javascript",
  "json",
  "lua",
  "python",
  "typescript",
  "tsx",
  "css",
  "rust",
  "java",
  "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enable = true


--
--
--
--
--
--
-- TODO: setup custom ascii image
-- alpha
--
-- https://github.com/Pytness/dotfiles/blob/master/.config/lvim/custom/dashboard.lua
-- ASCII_IMAGES_FOLDER = os.getenv("HOME") .. "/.config/lvim/static"
-- -- Ascii images have the extension .cat, and colored ascii images have
-- -- the extension .ccat,
-- --
-- -- Lolcat will only be used with the non colored ascii images
-- local function list_files(path, extension)
--     local files = {}
--     local pfile = io.popen("ls " .. path .. "/*" .. extension)
--
--     for filename in pfile:lines() do
--         table.insert(files, filename)
--     end
--
--     return files
-- end
--
-- local function get_random_ascii_image(path)
--
--     math.randomseed(os.clock())
--
--     -- For some reason ls *.(cat|ccat) will not work under vim,
--     -- so gotta ls twice and merge
--
--     local images = list_files(path, ".cat")
--     local colored_images = list_files(path, ".ccat")
--
--     for _, v in pairs(colored_images) do
--         table.insert(images, v)
--     end
--
--     return images[math.random(1, #images)]
-- end
--
-- local function remove_escaped_colors(str)
--     return str:gsub("\27%[[0-9;]*m", "")
-- end
--
-- local function get_ascii_image_dim(path)
--     local width = 0
--     local height = 0
--
--     local pfile = io.open(path, "r")
--
--     for line in pfile:lines() do
--         -- Take into account colored output
--         line = remove_escaped_colors(line)
--         local current_width = vim.fn.strdisplaywidth(line)
--         if current_width > width then
--             width = current_width
--         end
--         height = height + 1
--     end
--     return { width, height }
-- end
--
-- local function is_colored_image(path)
--     return path:sub(-4) == 'ccat'
-- end
--
-- local random_image = get_random_ascii_image(ASCII_IMAGES_FOLDER)
-- local image_width, image_height = unpack(get_ascii_image_dim(random_image))
--
-- image_height = 32
--
-- -- This avoids "process exited message"
-- local command = "cat | "
-- if is_colored_image(random_image) then
--     command = command .. "cat "
-- else
--     command = os.getenv("HOME") .. "/.config/lvim/static/animated_lolcat.sh "
-- end
--
--
--
-- local banner = {
--   "                ⢀⣀⣤⣤⣤⣶⣶⣶⣶⣶⣶⣤⣤⣤⣀⡀                ",
--   "             ⣀⣤⣶⣿⠿⠟⠛⠉⠉⠉⠁⠈⠉⠉⠉⠛⠛⠿⣿⣷⣦⣀             ",
--   "          ⢀⣤⣾⡿⠛⠉                ⠉⠛⢿⣷⣤⡀          ",
--   "         ⣴⣿⡿⠃                      ⠙⠻⣿⣦         ",
--   " ⢀⣠⣤⣤⣤⣤⣤⣾⣿⣉⣀⡀                        ⠙⢻⣷⡄       ",
--   "⣼⠋⠁   ⢠⣿⡟ ⠉⠉⠉⠛⠛⠶⠶⣤⣄⣀    ⣀⣀      ⢠⣤⣤⡄   ⢻⣿⣆      ",
--   "⢻⡄   ⢰⣿⡟        ⢠⣿⣿⣿⠉⠛⠲⣾⣿⣿⣷    ⢀⣾⣿⣿⠁    ⢻⣿⡆     ",
--   " ⠹⣦⡀ ⣿⣿⠁        ⢸⣿⣿⡇   ⠻⣿⣿⠟⠳⠶⣤⣀⣸⣿⣿⠇      ⣿⣷     ",
--   "   ⠙⢷⣿⡇         ⣸⣿⣿⠃          ⢸⣿⣿⢷⣤⡀     ⢸⣿⡆    ",
--   "    ⢸⣿⠇         ⣿⣿⣿     ⣿⣿⣷  ⢠⣿⣿⡏ ⠈⠙⠳⢦⣄  ⠈⣿⡇    ",
--   "    ⢸⣿⡆        ⢸⣿⣿⡇     ⣿⣿⣿ ⢀⣿⣿⡟      ⠈⠙⠷⣤⣿⡇    ",
--   "    ⠘⣿⡇        ⣼⣿⣿⠁     ⣿⣿⣿ ⣼⣿⣿⠃         ⢸⣿⠷⣄⡀  ",
--   "     ⣿⣿        ⣿⣿⡿      ⣿⣿⣿⢸⣿⣿⠃          ⣾⡿ ⠈⠻⣆ ",
--   "     ⠸⣿⣧      ⢸⣿⣿⣇⣀⣀⣀⣀⣀⣀⣸⣿⣿⣿⣿⠇          ⣼⣿⠇   ⠘⣧",
--   "      ⠹⣿⣧     ⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏          ⣼⣿⠏    ⣠⡿",
--   "       ⠘⢿⣷⣄   ⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉         ⢠⣼⡿⠛⠛⠛⠛⠛⠛⠉ ",
--   "         ⠻⣿⣦⣄                      ⣀⣴⣿⠟         ",
--   "          ⠈⠛⢿⣶⣤⣀                ⣀⣤⣶⡿⠛⠁          ",
--   "             ⠉⠻⢿⣿⣶⣤⣤⣀⣀⡀  ⢀⣀⣀⣠⣤⣶⣿⡿⠟⠋             ",
--   "                ⠈⠉⠙⠛⠻⠿⠿⠿⠿⠿⠿⠟⠛⠋⠉⠁                ",
-- }

local buttons = {
  opts = {
    hl_shortcut = "Include",
    spacing = 1,
  },
  entries = {
    { "f", lvim.icons.ui.FindFile .. "  Find File",   "<CMD>Telescope find_files<CR>" },
    { "n", lvim.icons.ui.NewFile .. "  New File",     "<CMD>ene!<CR>" },
    { "p", lvim.icons.ui.Project .. "  Projects ",    "<CMD>Telescope projects<CR>" },
    { "r", lvim.icons.ui.History .. "  Recent files", ":Telescope oldfiles <CR>" },
    { "t", lvim.icons.ui.FindText .. "  Find Text",   "<CMD>Telescope live_grep<CR>" },
    { "w", lvim.icons.ui.Note .. "  Wiki",            "<CMD>VimwikiIndex<CR>" },
    -- TODO: fix journal
    -- { "j", lvim.icons.ui.Note .. "  Journal", "<CMD>!$HOME/bin/journal<CR>" },
    {
      "c",
      lvim.icons.ui.Gear .. "  Configuration",
      "<CMD>edit " .. require("lvim.config"):get_user_config_path() .. " <CR>",
    },
  },
}
lvim.builtin.alpha.dashboard.section.buttons = buttons
lvim.builtin.alpha.dashboard.section.footer.val = ""
lvim.builtin.alpha.dashboard.section.header.val = ""

vim.opt.relativenumber = true
vim.opt.shellcmdflag = "-ic"
-- vim.opt.colorcolumn="80,120"
