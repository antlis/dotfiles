" ============================================================================ "
" ===                               PLUGINS                                === "
" ============================================================================ "

" check whether vim-plug is installed and install it if necessary
let plugpath = expand('<sfile>:p:h'). '/autoload/plug.vim'
if !filereadable(plugpath)
    if executable('curl')
        let plugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        call system('curl -fLo ' . shellescape(plugpath) . ' --create-dirs ' . plugurl)
        if v:shell_error
            echom "Error downloading vim-plug. Please install it manually.\n"
            exit
        endif
    else
        echom "vim-plug not installed. Please install it manually or install curl.\n"
        exit
    endif
endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'

call plug#begin()
" === Editing Plugins === "
" Trailing whitespace highlighting & automatic fixing
" Plug 'ntpeters/vim-better-whitespace'

" auto-close plugin
" Plug 'rstacruz/vim-closer'

" insert or delete brackets, parens, quotes in pair
Plug 'jiangmiao/auto-pairs'
" "https://stackoverflow.com/questions/21316727/automatic-closing-brackets-for-vim
" "inoremap " ""<left>
" "inoremap ' ''<left>
" "inoremap ( ()<left>
" "inoremap [ []<left>
" "inoremap { {}<left>
" "inoremap {<CR> {<CR>}<ESC>O
" "inoremap {;<CR> {<CR>};<ESC>O

" Improved motion in Vim
" Plug 'easymotion/vim-easymotion'

" Intellisense Engine
" Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Denite - Fuzzy finding, buffer management
" "if has('nvim')
" "  Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
" "else
" "  Plug 'Shougo/denite.nvim'
" "  Plug 'roxma/nvim-yarp'
" "  Plug 'roxma/vim-hug-neovim-rpc'
" "endif


" === UI === "
" File explorer
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }

" Customized vim status line
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Icons
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight', { 'on': 'NERDTreeToggle' }


" === Javascript Plugins === "
" Typescript syntax highlighting
Plug 'HerringtonDarkholme/yats.vim'

" ReactJS JSX syntax highlighting
Plug 'mxw/vim-jsx'

" Generate JSDoc commands based on function signature
" Plug 'heavenshell/vim-jsdoc'

" === Syntax Highlighting === "

" Syntax highlighting for nginx
" Plug 'chr4/nginx.vim'

" Syntax highlighting for javascript libraries
Plug 'othree/javascript-libraries-syntax.vim'
let g:used_javascript_libs = 'lodash,jquery,react,vue'

" Improved syntax highlighting and indentation
" Plug 'othree/yajs.vim'
Plug 'nathanaelkane/vim-indent-guides'

" There is issue with <tab>
" https://github.com/rstacruz/vim-hyperstyle/issues/8
" Plug 'rstacruz/vim-hyperstyle'

Plug 'rafi/awesome-vim-colorschemes'

" Languages
" Plug 'sheerun/vim-polyglot'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'nvim-treesitter/playground'
Plug 'ianks/vim-tsx', { 'for': ['tsx'] }
Plug 'leafgarland/typescript-vim', { 'for': ['ts', 'tsx'] }
Plug 'mboughaba/i3config.vim'
let g:yats_host_keyword = 1

" Utilities
" https://medium.com/@chemzqm/create-coc-nvim-extension-to-improve-vim-experience-4461df269173
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-sleuth'
Plug 'rhysd/git-messenger.vim'
Plug 'xolox/vim-misc'
Plug 'ruanyl/vim-gh-line'
Plug 'lambdalisue/vim-gista'
" Plug 'xolox/vim-notes', { 'on': 'Note' }
Plug 'xolox/vim-notes'
Plug 'dhruvasagar/vim-table-mode'
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
Plug 'francoiscabrol/ranger.vim'
Plug 'rbgrouleff/bclose.vim'
Plug 'mhinz/vim-signify'
Plug 'mhinz/vim-startify'
Plug 'dyng/ctrlsf.vim'
Plug 'pechorin/any-jump.vim'
Plug 'honza/vim-snippets'
Plug 'mpyatishev/vim-sqlformat', { 'for': ['sql'] }

Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

" Disable, I use fzf :Files instead
" Plug 'ctrlpvim/ctrlp.vim', { 'on': [] }

Plug 'moll/vim-node', { 'for': ['js', 'ts'] }
Plug 'dense-analysis/ale'
Plug 'jparise/vim-graphql'
" Plug 'eliba2/vim-node-inspect'
" Plug 'mfussenegger/nvim-dap'
Plug 'puremourning/vimspector'

" Use gcc to comment out a line (takes a count), gc to comment out the target of a motion (for example, gcap to comment out a paragraph), and gc in visual mode to comment out the selection.  That's it.
Plug 'tpope/vim-commentary'

Plug 'tpope/vim-surround'
Plug 'Valloric/MatchTagAlways', { 'for': ['html', 'xhtml', 'xml', 'jinja', 'svg', 'jsx', 'vue'] }

" Plug 'camspiers/animate.vim'
" Plug 'camspiers/lens.vim'
" Plug 'blueyed/vim-diminactive' TODO: figure out how to make this work
" Plug 'machakann/vim-highlightedyank'
" TODO: Move to plugin settings config dir
" highlight HighlightedyankRegion cterm=reverse gui=reverse
"
" https://github.com/MattesGroeger/vim-bookmarks

" https://medium.com/@jimeno0/eslint-and-prettier-in-vim-neovim-7e45f85cf8f9

" https://developpaper.com/integrated-usage-of-vim-and-fuzzy-search-artifact-fzf-from-simple-to-advanced/
" File navigation
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'rhysd/vim-fixjson'

Plug 'dracula/vim'

" Plug 'whatyouhide/vim-gotham'
" Plug 'kyazdani42/blue-moon'

" oepn browser text field in nvim
" Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

" Plug 'liuchengxu/vim-clap'

" Initialize plugin system
call plug#end()
