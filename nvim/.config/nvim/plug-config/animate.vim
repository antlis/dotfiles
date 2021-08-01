" animate vim
" nnoremap <silent> <Up>    :call animate#window_delta_height(10)<CR>
" nnoremap <silent> <Down>  :call animate#window_delta_height(-10)<CR>
" nnoremap <silent> <Left>  :call animate#window_delta_width(10)<CR>
" nnoremap <silent> <Right> :call animate#window_delta_width(-10)<CR>
"
" let g:fzf_layout = {
"  \ 'window': 'new | wincmd J | resize 1 | call animate#window_percent_height(0.5)'
" \ }
"
" function! OpenAnimatedHtop() abort
"   " Open a htop in terminal
"   new term://htop
"   " Send window to bottom and start with small height
"   wincmd J | resize 1
"   " Animate height to 66%
"   call animate#window_percent_height(0.66)
" endfunction
"
" let g:animate#duration = 300.0
"
" let g:animate#easing_func = 'animate#ease_linear'
