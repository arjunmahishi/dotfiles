call plug#begin('~/.vim/plugged')

Plug 'fatih/vim-go', { 'tag': '*' }
Plug 'kien/ctrlp.vim'
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'wakatime/vim-wakatime'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'airblade/vim-gitgutter'
Plug 'tomtom/tcomment_vim'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-fugitive'
Plug 'morhetz/gruvbox'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" look n feel
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

colorscheme gruvbox
syntax on

let g:gruvbox_contrast_dark = "hard"

set t_Co=256
set termguicolors
set background=dark

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



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" status line config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set noshowmode
let g:currentmode={'n':'NORMAL','v':'VISUAL','V':'V·LINE','':'V·BLOCK',
      \ 'i':'INSERT','R':'R','Rv':'V·REPLACE','c':'COMMAND'}

set statusline=
set statusline+=\ %{g:currentmode[mode()]}
set statusline+=%{GetGitBranch()}
set statusline+=\ \|\ %0.50f\ %y\ %r
set statusline+=%=
set statusline+=%p%%
set statusline+=\ \|\ %l,%-3c

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ctrl-p config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_map = '<c-p>'
let g:ctrlp_user_command = ['.git/',
  \ 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

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
au filetype go inoremap <buffer> . .<C-x><C-o>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" nerdtree config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:NERDTreeMinimalUI = 1
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" ack config
let g:ack_autoclose = 1

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
nnoremap <F4> :if (hlstate == 0) \| nohlsearch \| else \| set hlsearch \| endif \| let hlstate=1-hlstate<cr>

" switch between windows with leader key
nmap <leader>w <c-w><c-w>
nmap <leader>h <C-w>h
nmap <leader>j <C-w>j
nmap <leader>k <C-w>k
nmap <leader>l <C-w>l

" Go specific mapping
au filetype go nmap <leader>t :w<CR>:GoTestFunc<CR>
au filetype go nmap <leader>T :w<CR>:GoTest<CR>
au filetype go nmap <leader>r :w<CR>:GoRun<CR>

" Ruby specific mapping
au filetype ruby nmap <leader>r :w<CR>:!ruby %<CR>
au filetype ruby nmap <leader>t :w<CR>:execute "!zeus rspec %:" . line(".")<CR>

" Python specific mapping
au filetype python nmap <leader>r :w<CR>:!python %<CR>

" JS specific mapping
au filetype typescriptreact nmap <leader>t :w<CR>:split term://jest %<CR>G
au filetype javascriptreact nmap <leader>t :w<CR>:split term://jest %<CR>G

" Ack specific mapping
nmap <leader>a :Ack! "<c-r><c-w>"<CR>

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
" helper functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function GetGitBranch()
  let branchName = FugitiveHead()
  if branchName != "" 
    return "\  \|\ " . branchName
  endif
  return ""
endfunction
