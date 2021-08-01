" "let s:denite_options = {'default' : {
" "\ 'split': 'floating',
" "\ 'start_filter': 1,
" "\ 'auto_resize': 1,
" "\ 'source_names': 'short',
" "\ 'prompt': 'λ ',
" "\ 'highlight_matched_char': 'QuickFixLine',
" "\ 'highlight_matched_range': 'Visual',
" "\ 'highlight_window_background': 'Visual',
" "\ 'highlight_filter_background': 'DiffAdd',
" "\ 'winrow': 1,
" "\ 'vertical_preview': 1
" "\ }}

" === Denite shorcuts === "
"   ;         - Browser currently open buffers
"   <leader>t - Browse list of files in current directory
"   <leader>g - Search current directory for occurences of given term and close window if no results
"   <leader>j - Search current directory for occurences of word under cursor

" "nmap ; :Denite buffer<CR>
" "nmap <leader>t :DeniteProjectDir file/rec<CR>
" "nnoremap <leader>g :<C-u>Denite grep:. -no-empty<CR>
" "nnoremap <leader>j :<C-u>DeniteCursorWord grep:.<CR>
