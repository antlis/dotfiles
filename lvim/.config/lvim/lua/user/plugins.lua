-- Additional Plugins
--
-- https://github.com/folke/trouble.nvim
-- https://github.com/rhysd/git-messenger.vim
-- https://github.com/dracula/vim
-- https://github.com/whatyouhide/vim-gotham
-- https://github.com/vimwiki/vimwiki
-- https://github.com/jparise/vim-graphql
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
}
