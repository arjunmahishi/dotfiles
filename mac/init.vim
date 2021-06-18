call plug#begin('~/.vim/plugged')

Plug 'fatih/vim-go', { 'tag': '*' }
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'wakatime/vim-wakatime'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'airblade/vim-gitgutter'
Plug 'mileszs/ack.vim'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-fugitive'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'jremmen/vim-ripgrep'
Plug 'jvirtanen/vim-hcl'
Plug 'hashivim/vim-terraform'
Plug 'itchyny/lightline.vim'


" colorscheme
Plug 'lifepillar/vim-gruvbox8'
Plug 'ayu-theme/ayu-vim'
Plug 'arjunmahishi/onedark.vim'
Plug 'arcticicestudio/nord-vim'

call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" look n feel
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

syntax enable
set termguicolors
set background=dark
colorscheme onedark

set relativenumber
set number
set cursorline
set tabstop=2
set shiftwidth=2
set expandtab
set incsearch
set smartcase
set colorcolumn=81
set lazyredraw
set splitbelow
set splitright

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" " line config (lightline)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set noshowmode
let g:lightline = {
\ 'component_function': {
\   'filename': 'LightlineFilename',
\ },
\ 'colorscheme': 'onedark'
\ }

function! LightlineFilename()
  let root = fnamemodify(get(b:, 'git_dir'), ':h')
  let path = expand('%:p')
  if path[:len(root)-1] ==# root
    return path[len(root)+1:]
  endif
  return expand('%')
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-go config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
" au filetype go inoremap <buffer> . .<C-x><C-o>

" disable vim-go :GoDef short cut (gd)
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" nerdtree config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:NERDTreeMinimalUI = 1
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" ack config
let g:ack_autoclose = 1
let g:NERDTreeShowHidden=1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" custom key mapping
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader=","
let hlstate=0
imap jj <Esc>
imap kk <Esc>O
nmap vv :vsplit<CR>,l
nmap <C-s> :source ~/.config/nvim/init.vim<CR>
vmap <leader>y "*y
vmap <leader>p "*p
nmap <leader>o :NERDTreeToggle<CR>
nmap <leader>O :NERDTreeFind<CR>
nmap <leader><space> :nohlsearch<cr>
nmap <C-p> <cmd>Telescope find_files<cr>
nmap <C-f> <cmd>Telescope live_grep<cr>
nmap <C-c> <cmd>copen<cr>

" switch between windows with leader key
noremap <leader>w <c-w><c-w>
noremap <leader>h <C-w>h
noremap <leader>j <C-w>j
noremap <leader>k <C-w>k
noremap <leader>l <C-w>l

" Go specific mapping
au filetype go nmap <leader>t :w<CR>:GoTestFunc<CR>
au filetype go nmap <leader>T :w<CR>:GoTest<CR>
au filetype go nmap <leader>r :w<CR>:GoRun<CR>
au filetype go nmap <leader>b :GoDebugBreakpoint<CR>
au filetype go nmap <leader>d :GoDebugStart<CR>
au filetype go nmap <leader>s :GoDebugStop<CR>
au filetype go nmap <leader>n :GoDebugNext<CR>
au filetype go nmap <leader>c :GoDebugContinue<CR>

" Ruby specific mapping
au filetype ruby nmap <leader>r :w<CR>:!ruby %<CR>
au filetype ruby nmap <leader>t :w<CR>:execute "!zeus rspec %:" . line(".")<CR>
au filetype ruby nmap <leader>T :w<CR>:execute "!rspec %:" . line(".")<CR>

" Python specific mapping
au filetype python nmap <leader>r :w<CR>:!python %<CR>

" JS specific mapping
au filetype javascript nmap <leader>r :w<CR>:!node %<CR>
au filetype typescriptreact nmap <leader>t :w<CR>:split term://jest %<CR>G
au filetype javascriptreact nmap <leader>t :w<CR>:split term://jest %<CR>G
au filetype typescript nmap <leader>t :w<CR>:split term://jest %<CR>G

" Ack specific mapping
nmap <leader>a :Rg "<c-r><c-w>"<CR>

" BarBar mapping
nmap <C-j> :BufferPrevious<CR>
nmap <C-k> :BufferNext<CR>
nmap g1 :BufferGoto 1<CR>
nmap g2 :BufferGoto 2<CR>
nmap g3 :BufferGoto 3<CR>
nmap g4 :BufferGoto 4<CR>
nmap g5 :BufferGoto 5<CR>
nmap g6 :BufferGoto 6<CR>
nmap g7 :BufferGoto 7<CR>
nmap g8 :BufferGoto 8<CR>
nmap g9 :BufferLast<CR>
nmap <C-x> :BufferClose<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CoC config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:coc_global_extensions = ['coc-emmet', 'coc-css', 'coc-html', 
  \ 'coc-json', 'coc-prettier', 'coc-tsserver']

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not
" mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" BarBar config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let bufferline = get(g:, 'bufferline', {})
let bufferline.animation = v:false
let bufferline.icons = v:false
let bufferline.closable = v:true
let bufferline.clickable = v:true
let bufferline.icon_close_tab = ''
let bufferline.icon_close_tab_modified = '🔥'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" lua config 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

lua << EOF
require('telescope').setup{
  defaults = {
    file_ignore_patterns = {'node_modules', 'coverage'},
  }
}
EOF

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" helper functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function GetGitBranch()
  let branchName = FugitiveHead()
  if branchName != "" 
    return "\  \|\ " . branchName
  endif
  return ""
endfunction
