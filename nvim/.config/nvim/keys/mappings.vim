" Remap leader key to the spacebar
" if you what to find what is <Leader> bind to, use - echo mapleader

" Change mapleader
let g:mapleader = ","
" let g:mapleader = '\<Space>'
" nnoremap <silent> <leader>      :<c-u>WhichKey ','<CR>
" nnoremap <silent> <localleader> :<c-u>WhichKey  '<Space>'<CR>
nnoremap <silent> <leader> :<c-u>WhichKey  '<Space>'<CR>

imap jj <Esc>
map <silent> <F3> :NERDTreeToggle<CR>
map <silent> <F4> :syntax sync fromstart<CR>
imap cll console.debug()<Esc>==f(a

" FZF
nmap // :BLines!<CR>
nmap ?? :Rg!<CR>
nmap cc :Commands!<CR>
map <silent> <F2> :GFiles<CR>
map <silent> <c-p> :GFiles<CR>
nmap <silent><leader>b :Buffers<CR>

" https://superuser.com/questions/271023/can-i-disable-continuation-of-comments-to-the-next-line-in-vim
" Not working for some reason, only when manually lunch it via :
" set formatoptions-=cro
nnoremap <Leader>o o<Esc>^Da
nnoremap <Leader>O O<Esc>^Da

" Use preset argument to open it
nmap <Leader>ed :CocCommand explorer --preset .vim<CR>
nmap <Leader>ef :CocCommand explorer --preset floatingRightside<CR>

" List all presets
nmap <Leader>el :CocList explPresets

" Toggle explorer
map - :NERDTreeToggle<CR>
" map - :CocCommand explorer --preset default<CR>

" AnyJump
" Normal mode: Jump to definition under cursore
nnoremap <leader>j :AnyJump<CR>
" Visual mode: jump to selected text in visual mode
xnoremap <leader>j :AnyJumpVisual<CR>
" Normal mode: open previous opened file (after jump)
nnoremap <leader>ab :AnyJumpBack<CR>
" Normal mode: open last closed search window again
nnoremap <leader>al :AnyJumpLastResults<CR>
