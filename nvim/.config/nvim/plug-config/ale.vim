" let g:ale_sign_error = '❌'
let g:ale_sign_error = '🔥 '
" let g:ale_sign_error = '☠️ '
let g:ale_sign_warning = '☢️ '
" let g:ale_sign_warning = '🚨 '
" let g:ale_sign_warning = '⚡'

let g:LanguageClient_serverCommands = {
    \ 'vue': ['vls']
    \ }

" bracket color match
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['tsserver', 'tslint'],
\   'vue': ['eslint']
\}

let g:ale_fixers = {
\     '*': ['remove_trailing_lines', 'trim_whitespace'],
\    'javascript': ['eslint'],
\    'typescript': ['prettier'],
\    'vue': ['eslint', 'prettier'],
\    'scss': ['prettier'],
\    'json': ['fixjson']
\}
let g:ale_linters_explicit = 1
" let g:ale_fix_on_save = 1

" https://stackoverflow.com/questions/38458067/which-eslint-rules-in-my-config-are-slow
let g:ale_javascript_eslint_executable = 'eslint_d --cache'
