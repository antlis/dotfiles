" ============ NerdTree ============

" NERDTree settings
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let NERDTreeQuitOnOpen = 1
let g:NERDTreeWinSize = 40
let g:NERDTreeWinPos = "right"
" Remove bookmarks and help text from NERDTree
let NERDTreeMinimalUI=1

" https://github.com/tiagofumo/vim-nerdtree-syntax-highlight
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1

let g:NERDTreeHighlightFolders = 1 " enables folder icon highlighting using exact match
let g:NERDTreeHighlightFoldersFullName = 1 " highlights the folder name

" Show hidden files/directories
let NERDTreeShowHidden=1

" Hide certain files and directories from NERDTree
let g:NERDTreeIgnore = ['^\.DS_Store$', '^tags$', '\.git$[[dir]]', '\.idea$[[dir]]', '\.sass-cache$']

" Custom icons for expandable/expanded directories
let g:NERDTreeDirArrowExpandable = '⬏'
let g:NERDTreeDirArrowCollapsible = '⬎'

" https://github.com/neoclide/coc.nvim/issues/518
if globpath(&runtimepath, 'autoload/nerdtree.vim') !=# ''
    nmap <silent><c-n> :NERDTreeToggle<cr>

    let NERDTreeAutoDeleteBuffer = 1

    " Remove bookmarks and help text from NERDTree
    let nerdtreeminimalui = 1
endif
