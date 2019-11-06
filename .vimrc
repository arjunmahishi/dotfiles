set rtp+=~/.vim/bundle/Vundle.vim

execute pathogen#infect()
syntax on
color jellybeans

set number
map <C-O> :NERDTreeToggle<CR>
set rtp+=~/.fzf

call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" general plugins
Plugin 'Valloric/YouCompleteMe'
Plugin 'tomtom/tcomment_vim' 

" Airline plugins
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Git plugins
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'

call vundle#end() 

filetype plugin indent on

" vim-go customizations
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:syntastic_go_checkers = ['go', 'golint', 'govet', 'errcheck']

" Open go doc in vertical window, horizontal, or tab
au Filetype go nnoremap <leader>v :vsp <CR>:exe "GoDef" <CR>
au Filetype go nnoremap <leader>s :sp <CR>:exe "GoDef"<CR>
" au Filetype go nnoremap <leader>t :tab split <CR>:exe "GoDef"<CR>

" Airline customizations
let g:airline_powerline_fonts=1
let g:airline_theme='jellybeans'
set t_Co=256

set tabstop=4
set shiftwidth=4
set expandtab
