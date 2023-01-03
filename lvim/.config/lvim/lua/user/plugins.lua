-- Additional Plugins
--
-- https://github.com/folke/trouble.nvim
-- https://github.com/rhysd/git-messenger.vim
-- https://github.com/dracula/vim
-- https://github.com/whatyouhide/vim-gotham
-- https://github.com/vimwiki/vimwiki
-- https://github.com/jparise/vim-graphql
-- https://github.com/mattn/emmet-vim
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
  --
  --
  -- Going to use this plugin plus LSP
  -- https://github.com/LunarVim/LunarVim/issues/1386
  -- use <C+y+,> to expand
  "mattn/emmet-vim",
}
