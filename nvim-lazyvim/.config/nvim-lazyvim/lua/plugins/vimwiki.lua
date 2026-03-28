return {
  "vimwiki/vimwiki",
  init = function()
    vim.g.vimwiki_global_ext = 0
    vim.g.vimwiki_filetypes = { "markdown" }
    vim.g.vimwiki_list = {
      {
        path = '~/Documents/notes/',
        syntax = 'markdown',
        ext = '.md',
      },
    }
  end,
}
