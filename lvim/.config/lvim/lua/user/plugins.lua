-- Additional Plugins
--
-- https://github.com/folke/trouble.nvim
-- https://github.com/rhysd/git-messenger.vim
-- https://github.com/dracula/vim
-- https://github.com/whatyouhide/vim-gotham
-- https://github.com/vimwiki/vimwiki
-- https://github.com/jparise/vim-graphql
-- https://github.com/gpanders/editorconfig.nvim
-- https://github.com/xiyaowong/telescope-emoji.nvim
-- https://github.com/francoiscabrol/ranger.vim
-- https://github.com/ruanyl/vim-gh-line
-- https://github.com/mattn/emmet-vim
-- https://github.com/mfussenegger/nvim-dap
-- https://github.com/tzachar/cmp-tabnine
-- https://github.com/stevearc/oil.nvim
-- https://github.com/Exafunction/codeium.vim
-- https://github.com/kylechui/nvim-surround
--
lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = {
      "Trouble",
      "TroubleToggle",
      "TroubleRefresh",
      "TroubleClose",
    },
  },
  "rhysd/git-messenger.vim",
  "dracula/vim",
  "whatyouhide/vim-gotham",
  "vimwiki/vimwiki",
  "jparise/vim-graphql",
  "gpanders/editorconfig.nvim",
  "xiyaowong/telescope-emoji.nvim",
  "francoiscabrol/ranger.vim",
  "ruanyl/vim-gh-line",
  --
  --
  -- Going to use this plugin plus LSP
  -- https://github.com/LunarVim/LunarVim/issues/1386
  -- use <C+y+,> to expand
  "mattn/emmet-vim",

  "mfussenegger/nvim-dap",

  {
    "tzachar/cmp-tabnine",
    event = "BufRead",
    build = "./install.sh",
    dependencies = 'hrsh7th/nvim-cmp',
  },
  {
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    -- dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit",
      -- "Glog", -- Not working for some reason
    },
    ft = {"fugitive"}
  },
  {
    "sindrets/diffview.nvim",
    event = "BufRead",
  },
  -- "neoclide/coc.nvim",
  -- "Exafunction/codeium.vim",
  "kylechui/nvim-surround",
}

require("telescope").load_extension("emoji")
lvim.builtin.telescope.defaults.layout_config.width = 0.95
-- lvim.builtin.telescope.defaults.layout_config.height = 0.75
-- lvim.builtin.telescope.defaults.layout_config.preview_cutoff = 75
lvim.builtin.telescope.defaults.file_ignore_patterns = {
  "node_modules",
  ".git",
}
lvim.builtin.telescope.defaults.path_display = { "absolute" }
-- lvim.builtin.telescope.defulats.find_files = {
--   -- use fd to "find files" and return absolute paths
-- 	find_command = { "fd", "-t=f", "-a" },
-- 	path_display = { "absolute" },
--   wrap_results = true
-- }
