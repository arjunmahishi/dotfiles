--            _                      _    _    _    _
--   __ _ _ _(_)_  _ _ _  _ __  __ _| |_ (_)__| |_ (_)
--  / _` | '_| | || | ' \| '  \/ _` | ' \| (_-| ' \| |
--  \__,_|_|_/ |\_,_|_||_|_|_|_\__,_|_||_|_/__|_||_|_|
--         |__/
--
--                            https://arjunmahishi.com
--                     https://github.com/arjunmahishi
--                    https://twitter.com/arjunmahishi

----------------------------------
--        Plugins
----------------------------------

local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.vim/plugged')

Plug('fatih/vim-go', { tag = '*' })
Plug('preservim/nerdtree')
Plug('neoclide/coc.nvim', { ['do'] = 'yarn install --frozen-lockfile'})
Plug('wakatime/vim-wakatime')
Plug('tpope/vim-surround')
Plug('jiangmiao/auto-pairs')
Plug('airblade/vim-gitgutter')
Plug('mileszs/ack.vim')
Plug('tomtom/tcomment_vim')
Plug('tpope/vim-fugitive')
Plug('nvim-lua/popup.nvim')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('romgrk/barbar.nvim')
Plug('kyazdani42/nvim-web-devicons')
Plug('jvirtanen/vim-hcl')
Plug('hashivim/vim-terraform')
Plug('buoto/gotests-vim')
Plug('AndrewRadev/splitjoin.vim')
Plug('SirVer/ultisnips')
Plug('gelguy/wilder.nvim', { ['do'] = ':UpdateRemotePlugins' })
Plug('mg979/vim-visual-multi', { branch = 'master'})
Plug('jbyuki/venn.nvim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate'})
Plug('nvim-neorg/neorg')
Plug('ThePrimeagen/vim-apm')
Plug 'nvim-lualine/lualine.nvim'
Plug 'neovim/nvim-lspconfig' -- TODO: yet to be configured
Plug 'voldikss/vim-floaterm'

-- colorscheme
Plug('lifepillar/vim-gruvbox8')
Plug('ayu-theme/ayu-vim')
Plug('arjunmahishi/onedark.vim')
Plug('arcticicestudio/nord-vim')

Plug('ryanoasis/vim-devicons')

vim.call('plug#end')

----------------------------------
--        basic settings
----------------------------------

vim.cmd 'syntax enable'
vim.cmd 'colorscheme onedark'

vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.opt.colorcolumn = '121'
vim.opt.lazyredraw = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.mouse = 'a'
vim.opt.encoding = 'utf8'
vim.opt.guifont = 'Fira Code'
vim.opt.showmode = false

----------------------------------
--     custom key mapping
----------------------------------

vim.g.mapleader = ' '

local map = vim.api.nvim_set_keymap
local noremap = { noremap = true }

map('i', 'jj', '<Esc>', {})
map('n', 'vv', ':vsplit<CR> l', {})
map('n', 'tt', ':tabnew<CR>', {})
map('n', '<C-s>', ':source ~/.config/nvim/init.lua<CR>', {})
map('v', '<leader>y', '"+y', {})
map('n', '<leader>p', '"+p', {})
map('n', '<C-l>', ':nohlsearch<cr>', {})

-- switching between panes
map('n', '<leader>w', '<c-w><c-w>', noremap)
map('n', '<leader>h', '<c-w>h', noremap)
map('n', '<leader>j', '<c-w>j', noremap)
map('n', '<leader>k', '<c-w>k', noremap)
map('n', '<leader>l', '<c-w>l', noremap)

-- BarBar
map('n', '<C-j>', ':BufferPrevious<CR>', {})
map('n', '<C-k>', ':BufferNext<CR>', {})
map('n', '<C-x>', ':BufferClose<CR>', {})

-- formatting
vim.cmd [[
  au filetype json nmap <leader>f :%!jq '.' %<CR>
  au filetype hcl nmap <leader>f :%!hclfmt %<CR>
]]

-- terminal
map('t', '<Esc>', '<C-\\><C-n>', noremap)

-- float term
map('n', 'gt', ':FloatermToggle<cr>', noremap)

-- golang
vim.cmd [[
  au filetype go nmap <leader>t :w<CR>:GoTestFunc<CR>
  au filetype go nmap <leader>T :w<CR>:GoTest<CR>
  au filetype go nmap <leader>r :w<CR>:GoRun<CR>
  au filetype go nmap <leader>b :GoDebugBreakpoint<CR>
  au filetype go nmap <leader>d :GoDebugStart<CR>
  au filetype go nmap <leader>s :GoDebugStop<CR>
  au filetype go nmap <leader>n :GoDebugNext<CR>
  au filetype go nmap <leader>c :GoDebugContinue<CR>
  au filetype go nmap <leader>i <Plug>(go-info)
]]

-- ruby
vim.cmd [[
  au filetype ruby nmap <leader>r :w<CR>:!ruby %<CR>
  au filetype ruby nmap <leader>t :w<CR>:execute "!zeus rspec %:" . line(".")<CR>
  au filetype ruby nmap <leader>T :w<CR>:execute "!rspec %:" . line(".")<CR>
]]

-- python
vim.cmd [[
  au filetype python nmap <leader>r :w<CR>:!python %<CR>
]]

-- javascript
vim.cmd [[
  au filetype javascript nmap <leader>r :w<CR>:!node %<CR>
  au filetype typescriptreact nmap <leader>t :w<CR>:split term://jest %<CR>G
  au filetype javascriptreact nmap <leader>t :w<CR>:split term://jest %<CR>G
  au filetype typescript nmap <leader>t :w<CR>:split term://jest %<CR>G
]]

----------------------------------
--     lualine
----------------------------------

require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_lsp', 'coc'}}},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

----------------------------------
--     vim-go
----------------------------------

vim.g.go_highlight_fields = 1
vim.g.go_highlight_functions = 1
vim.g.go_highlight_function_calls = 1
vim.g.go_highlight_extra_types = 1
vim.g.go_highlight_operators = 1
vim.g.go_fmt_autosave = 1
vim.g.go_fmt_command = "goimports"
-- vim.g.go_def_mapping_enabled = 0
vim.g.go_auto_type_info = 1

----------------------------------
--    NERD tree
----------------------------------

vim.g.NERDTreeMinimalUI = 1
vim.g.NERDTreeShowHidden = 1

map('n', '<leader>o', ':NERDTreeToggle<CR>', {})
map('n', '<leader>O', ':NERDTreeFind<CR>', {})

-- automatically close NERDTree if thats the only thing open
vim.cmd [[
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
]]

----------------------------------
--    Wilder
----------------------------------

vim.cmd [[
  call wilder#setup({'modes': [':', '/', '?']})
  call wilder#set_option('renderer', wilder#popupmenu_renderer(wilder#popupmenu_border_theme({ 'highlights': { 'border': 'Normal' }, 'border': 'rounded' })))
]]

----------------------------------
--    multi select
----------------------------------

vim.g.VM_maps = { ['Find Under'] = '<C-d>', ['Find Subword Under'] = '<C-d>' }

----------------------------------
--   utilsnips
----------------------------------

vim.g.UltiSnipsExpandTrigger = '<c-space>'
vim.g.UltiSnipsJumpForwardTrigger = '<c-k>'
vim.g.UltiSnipsJumpBackwardTrigger = '<c-j>'

----------------------------------
--   telescope
----------------------------------

local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    file_ignore_patterns = {'node_modules', 'coverage'},
    mapping = { i = { ["<esc>"] = actions.close } }
  }
}

map('n', '<C-p>', '<cmd>Telescope find_files<CR>', {})
map('n', '<C-f>', '<cmd>Telescope live_grep<CR>', {})

----------------------------------
--   barbar
----------------------------------

vim.g.bufferline = {
  auto_hide = false,
  tabpages = true,
  closable = true,
  clickable = true,
  icons = true,
  icon_separator_active = '▎',
  icon_separator_inactive = '▎',
  icon_close_tab = 'x',
  icon_close_tab_modified = '🔥',
}

----------------------------------
--   coc
----------------------------------

vim.g.coc_global_extensions = {
  'coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-tsserver'
}

-- if hidden is not set, TextEdit might fail.
vim.opt.hidden = true
-- Better display for messages
vim.opt.cmdheight = 2
-- Smaller updatetime for CursorHold & CursorHoldI
vim.opt.updatetime = 300
-- don't give |ins-completion-menu| messages.
vim.opt.shortmess:append('c')
-- always show signcolumns
vim.opt.signcolumn = 'yes'

map('i', '<silent><expr> <TAB>', 'pumvisible() ? "<C-n>" : <SID>check_back_space() ? "<TAB>" : coc#refresh()', noremap)
map('i', '<expr><S-TAB>', 'pumvisible() ? "<C-p>" : "<C-h>"', noremap)

function check_back_space()
  local col = col('.') - 1
  return col ~= nil or getline('.')[col-1]:match '%s'
end

-- ctrl+space to trigger complete
map('n', '<silent><expr>', '<c-space> coc#refresh()', {})

-- navigate diagnostic
map('n', '<silent> [c','<Plug>(coc-diagnostic-prev)', {})
map('n', '<silent> ]c','<Plug>(coc-diagnostic-next)', {})

-- remap keys for gotos
-- map('n', '<silent> gd', '<Plug>(coc-definition)', {})
map('n', '<silent> gy', '<Plug>(coc-type-definition)', {})
map('n', '<silent> gi', '<Plug>(coc-implementation)', {})
map('n', '<silent> gr', '<Plug>(coc-references)', {})

----------------------------------
--   neorg
----------------------------------

require('neorg').setup {
  load = {
      ["core.defaults"] = {}, -- Load all the default modules
      ["core.norg.concealer"] = {}, -- Allows for use of icons
      ["core.norg.dirman"] = { -- Manage your directories with Neorg
          config = {
              workspaces = {
                  my_workspace = "~/neorg"
              }
          }
      }
  },
}

----------------------------------
--   treesitter
----------------------------------

-- TODO: figure this shit out
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
-- require('nvim-treesitter.parsers').get_parser_configs().norg = {
--     install_info = {
--         url = "https://github.com/nvim-neorg/tree-sitter-norg",
--         files = { "src/parser.c", "src/scanner.cc" },
--         branch = "main"
--     },
-- }
