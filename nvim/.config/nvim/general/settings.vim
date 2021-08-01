
" ================ Sensible/Opinion overrides ======================


" Set nohlsearch
set nohlsearch

" Override Opinion fold method
set foldmethod=manual
set foldnestmax=10
set nofoldenable
set foldlevel=1

" Override numberwidth
set numberwidth=1

" https://github.com/vim/vim/issues/2790
" Should fix syntax hightlight disappears
syntax sync minlines=10000

" https://jeffkreeftmeijer.com/vim-number/
" turn hybrid line numbers on
" :set number relativenumber
" :set nu rnu

set number relativenumber

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" https://www.reddit.com/r/vim/comments/7j9znw/gx_failing_to_open_url_on_vim8/
" gx open link in browser
" let g:netrw_browsex_viewer= "xdg-open"

" https://github.com/vim/vim/issues/4738
nmap gx yiW:!xdg-open <cWORD><CR> <C-r>" & <CR><CR>

" https://stackoverflow.com/questions/51272493/resolving-javascript-modules-via-gf-in-vim-when-using-a-webpack-tilde-alias
" set includeexpr=substitute(substitute(v:fname,'^\\@\/','resources/assets/js/',''),'^\\@sass/\\(.*\\)/\\(.*\\)$','resources/assets/sass/\\1/_\\2','')
" set suffixesadd=.js,.vue,.scss
