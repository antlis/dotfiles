" https://adminhacks.com/vim-javascript.html
" TODO: https://www.linux.org.ru/forum/desktop/9665841
scriptencoding utf-8

" $HOME/.config/nvim

" General settings
" if !exists('g:vscode')
"   source $HOME/.config/nvim/plug-config/polyglot.vim
" endif
source $HOME/.config/nvim/plugins.vim
source $HOME/.config/nvim/abbriviations.vim
source $HOME/.config/nvim/general/settings.vim
source $HOME/.config/nvim/keys/mappings.vim

if exists('g:vscode')
  " VS Code extension
  source $HOME/.config/nvim/vscode/settings.vim
  " source $HOME/.config/nvim/plug-config/easymotion.vim
  " source $HOME/.config/nvim/plug-config/highlightyank.vim
endif

" Plugin Configuration
source $HOME/.config/nvim/plug-config/airline.vim
source $HOME/.config/nvim/plug-config/ale.vim
" source $HOME/.config/nvim/plug-config/animate.vim
source $HOME/.config/nvim/plug-config/coc.vim
source $HOME/.config/nvim/plug-config/ctrlp.vim
" source $HOME/.config/nvim/plug-config/denite.vim
" source $HOME/.config/nvim/plug-config/emmet.vim
source $HOME/.config/nvim/plug-config/nerdtree.vim
source $HOME/.config/nvim/plug-config/ranger.vim
source $HOME/.config/nvim/plug-config/vim-fugitive.vim
source $HOME/.config/nvim/plug-config/vim-notes.vim
source $HOME/.config/nvim/plug-config/markdown-preview.vim

" TODO: move to separate config file
" TODO: configure colors
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=red   ctermbg=3
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=4

" https://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118
" Syntax highlight issue https://stackoverflow.com/questions/14779299/syntax-highlighting-randomly-disappears-during-file-saving

" setlocal foldmethod=syntax
" augroup vimrc
"   au BufReadPre * setlocal foldmethod=indent
"   au BufWinEnter * if &fdm == 'indent' | setlocal foldmethod=manual | endif
" augroup END


" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Enable true color support
" set termguicolors
color dracula
" set termguicolors
" colorscheme blue-moon
" colorscheme gotham256

" Change vertical split character to be a space (essentially hide it)
" https://vi.stackexchange.com/questions/22053/how-to-completely-hide-the-seperator-between-windows
set fillchars+=vert:\ ,

" set shell=usr/bin/zsh
set clipboard+=unnamedplus
set nu
" set rnu

" https://www.linux.com/training-tutorials/using-spell-checking-vim/
" SPELLCHECKING
" set spell spelllang=en_us
" set spell spelllang=ru_ru

" http://vimcasts.org/episodes/neovim-eyecandy/
set inccommand=split

filetype on

" On pressing tab, insert 2 spaces
" set expandtab
" show existing tab with 2 spaces width
" set tabstop=2
" set softtabstop=2
" when indenting with '>', use 2 spaces width
" set shiftwidth=2

" set list
set lcs+=space:·
hi Whitespace ctermfg=grey guifg=grey70
" hi VertSplit ctermbg=dark

set hlsearch
set ignorecase
set smartcase
set mouse=a

" Highlight matching stuff
set showmatch

" https://gist.github.com/latentflip/57bf8f9edde531ee979e
set suffixesadd+=.js
set path+=$PWD/node_modules
" https://stackoverflow.com/questions/51272493/resolving-javascript-modules-via-gf-in-vim-when-using-a-webpack-tilde-alias
" set inex=substitute(v:fname,'^\\~','$PWD/node_modules','')

" syntax on
" set syntax=whitespace
" set spell
" https://github.com/genoma/NeoFront/blob/master/init.vim


" syntax enable
" https://github.com/Shougo/dein.vim

" TODO: Intredesting
" https://github.com/rhysd/NyaoVim

" column boundry
set colorcolumn=+1        " highlight column after 'textwidth'
set colorcolumn=+1,+2,+3  " highlight three columns after 'textwidth'
" set colorcolumn=80
set colorcolumn=120
" column boundry

" Persistent undo https://stackoverflow.com/questions/5700389/using-vims-persistent-undo
" Put plugins and dictionaries in this dir (also on Windows)
let vimDir = '$HOME/.vim'
let &runtimepath.=','.vimDir
" Keep undo history across sessions by storing it in a file
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undodir')
    " Create dirs
    call system('mkdir ' . vimDir)
    call system('mkdir ' . myUndoDir)
    let &undodir = myUndoDir
    set undofile
endif
" bracket color match
" https://stackoverflow.com/questions/10746750/set-vim-bracket-highlighting-colors
hi MatchParen cterm=none ctermbg=green ctermfg=blue
hi MatchParen cterm=bold ctermbg=none ctermfg=magenta

augroup CursorLineOnlyInActiveWindow
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END


" For some reason this dosent work if I'll place it in the beginning of vimrc
" https://superuser.com/questions/271023/can-i-disable-continuation-of-comments-to-the-next-line-in-vim
au FileType * set fo-=c fo-=r fo-=o


command! FileHistory execute ":BCommits!"

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = true,
  },
  matchup = {
    enable = true
  },
  autotag = {
    enable = true
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}
EOF
