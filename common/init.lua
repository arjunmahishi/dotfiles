--
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

-- telescope
Plug('nvim-lua/popup.nvim')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })

-- treesitter
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate'})
Plug('nvim-treesitter/playground')

Plug('fatih/vim-go', { tag = '*' })
Plug('preservim/nerdtree')
Plug('wakatime/vim-wakatime')
Plug('tpope/vim-surround')
Plug('jiangmiao/auto-pairs')
Plug('lewis6991/gitsigns.nvim')
Plug('tomtom/tcomment_vim')
Plug('tpope/vim-fugitive')
Plug('romgrk/barbar.nvim')
Plug('jvirtanen/vim-hcl')
Plug('hashivim/vim-terraform')
Plug('buoto/gotests-vim')
Plug('AndrewRadev/splitjoin.vim')
Plug('mg979/vim-visual-multi', { branch = 'master'})
Plug('nvim-neorg/neorg')
Plug('nvim-lualine/lualine.nvim')
Plug('neovim/nvim-lspconfig')
Plug('voldikss/vim-floaterm')
Plug('iamcco/markdown-preview.nvim', { ['do'] = 'cd app && yarn install' })
Plug('arjunmahishi/run-code.nvim')
Plug('ThePrimeagen/git-worktree.nvim')
Plug('rcarriga/nvim-notify')
Plug('williamboman/nvim-lsp-installer')
-- Plug('github/copilot.vim')

-- auto completion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-nvim-lua')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')

-- colorscheme
-- Plug('lifepillar/vim-gruvbox8')
-- Plug('ayu-theme/ayu-vim')
Plug('arjunmahishi/onedark.vim')
-- Plug('arcticicestudio/nord-vim')
-- Plug 'marko-cerovac/material.nvim'

Plug('kyazdani42/nvim-web-devicons')
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
vim.opt.colorcolumn = '81'
vim.opt.lazyredraw = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.mouse = 'a'
vim.opt.encoding = 'utf8'
vim.opt.guifont = 'Fira Code Nerd'
vim.opt.showmode = false
vim.opt.scrolloff = 10
vim.opt.hlsearch = false
vim.opt.inccommand = 'split'
vim.opt.wrap = false
-- vim.opt.list = true
-- vim.opt.listchars = 'tab:→\ ,trail:∙,nbsp:•'
-- vim.opt.listchars = { space = '•', tab = '→' }

vim.cmd [[
  au TextYankPost * silent! lua vim.highlight.on_yank()
]]

vim.g.material_style = "deep ocean"

----------------------------------
--     custom key mapping
----------------------------------

vim.g.mapleader = ' '

local map = vim.api.nvim_set_keymap
local noremap = { noremap = true }

map('i', 'jj', '<Esc>', {})
map('n', 'vv', ':vnew<CR>', {})
map('n', 'tt', ':tabnew<CR>', {})
map('n', '<C-s>', ':source ~/.config/nvim/init.lua<CR>', {})
map('v', '<leader>y', '"+y', {})
map('n', '<leader>p', '"+p', {})
map('n', '<C-l>', ':nohlsearch<cr>', {})
map('n', '<leader>fd', ':lua open_file_in_repo()<cr>', {})

-- since space is used as the supream leader, make sure that is doesn't do anything
-- else. Because no one should have that much power
map('n', '<SPACE>', '<Nop>', noremap)
map('v', '<SPACE>', '<Nop>', noremap)

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

-- terminal
map('t', '<Esc>', '<C-\\><C-n>', noremap)

-- float term
map('n', 'gt', ':FloatermToggle<cr>', noremap)

-- formatting
vim.cmd [[
  au filetype json nmap <leader>f :%!jq '.' %<CR>
  au filetype hcl nmap <leader>f :%!hclfmt %<CR>
]]

-- quickfix
map('n', '<leader>q', ':lua vim.lsp.diagnostic.set_loclist()<CR>', {})
map('n', '<leader>]', ':cnext<cr>', noremap)
map('n', '<leader>[', ':cprevious<cr>', noremap)

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
  au filetype ruby nmap <leader>t :w<CR>:execute "!zeus rspec %:" . line(".")<CR>
  au filetype ruby nmap <leader>T :w<CR>:execute "!rspec %:" . line(".")<CR>
]]

-- javascript
vim.cmd [[
  au filetype typescriptreact nmap <leader>t :w<CR>:split term://jest %<CR>G
  au filetype javascriptreact nmap <leader>t :w<CR>:split term://jest %<CR>G
  au filetype typescript nmap <leader>t :w<CR>:split term://jest %<CR>G
]]

----------------------------------
--     automation
----------------------------------

-- format hcl files on save
-- vim.cmd[[
--   au BufWritePost *.hcl* silent! exec "%!hclfmt %" | w
-- ]]

----------------------------------
--     custom commands
----------------------------------

local function command(name, cmd)
  vim.cmd(string.format("command! -nargs=* %s %s", name, cmd))
end

command('Config', ':lua open_config()')
command('Notes', ':lua telescope_into_dir("~/notes")')
command('NewNote', ':lua create_new_note()')
command('Scratch', ':lua scratch_buffer(<f-args>)')

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
    lualine_b = {'branch', 'diff'},
    lualine_c = {{ 'filename', path = 1 }},
    lualine_x = {'encoding', 'filetype', {'diagnostics', sources={'nvim_lsp'}}},
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
--    multi select
----------------------------------

vim.g.VM_maps = { ['Find Under'] = '<C-d>', ['Find Subword Under'] = '<C-d>' }

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

require('telescope').load_extension('fzf')
require("telescope").load_extension("git_worktree")

map('n', '<C-p>', '<cmd>lua telescope_into_dir(".")<CR>', {})
map('n', '<leader>w', '<cmd>lua telescope_into_dir("~/work")<CR>', {})
map('n', '<C-f>', '<cmd>Telescope live_grep theme=ivy<CR>', {})

----------------------------------
--   git-worktree
----------------------------------

map('n', '<C-g>', "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>", {})

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
  indent = {
    enable = true
  }
}

require('nvim-treesitter.parsers').get_parser_configs().norg = {
  install_info = {
    url = "https://github.com/nvim-neorg/tree-sitter-norg",
    files = { "src/parser.c", "src/scanner.cc" },
    branch = "main"
  },
}

----------------------------------
--   run-code
----------------------------------

map('v', '<leader>r', ':RunCodeSelected<CR>', {})
map('n', '<leader>r', ':RunCodeFile<CR>', {})
vim.cmd [[
  au filetype markdown nmap <leader>R :RunCodeBlock<CR>
]]

----------------------------------
--   nvim-cmp
----------------------------------

local nvim_lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local cmp = require('cmp')

local cmp_icons = {
  Text = " ", Method = " ", Function = " ", Constructor = " ", Field = " ", Variable = " ", Class = "ﴯ ",
  Interface = " ", Module = " ", Property = "ﰠ ", Unit = " ", Value = " ", Enum = " ", Keyword = " ",
  Snippet = " ", Color = " ", File = " ", Reference = " ", Folder = " ", EnumMember = " ",
  Constant = " ", Struct = " ", Event = " ", Operator = " ", TypeParameter = " "
}

-- returns a cmp select function based on the direction
local function cmp_move(direction)
  local move = cmp.select_next_item
  if direction == "prev" then
    move = cmp.select_prev_item
  end

  return function (fallback)
    if cmp.visible() then
      move()
      return
    end
    fallback()
  end
end

local mapping = {
  ['<CR>'] = cmp.mapping.confirm {
    behavior = cmp.ConfirmBehavior.Replace,
    select = true,
  },
  ['<C-SPACE>'] = cmp.mapping.complete(),
  -- ['<Tab>'] = cmp_move("next"),
  -- ['<S-Tab>'] = cmp_move("prev"),
}

cmp.setup {
  snippet = {
    expand = function(args)
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'buffer' },
    { name = 'path' },
  },
  mapping = mapping,
  formatting = {
    format = function(entry, item)
      item.kind = cmp_icons[item.kind] or ""
      item.menu = ({
        buffer = "[B]",
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        nvim_lua = "[Lua]",
        latex_symbols = "[LaTeX]",
      })[entry.source.name]
      return item
    end
  }
}

-- auto complete for search
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  },
  mapping = mapping
})

-- auto complete for commands
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  mapping = mapping
})


vim.o.completeopt = 'menu,menuone'
----------------------------------
--     lsp config
----------------------------------
local servers = { 'gopls' }

-- iterate over each of the servers and setup each of them
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    capabilities = capabilities,
    flags = { debounce_text_changes = 150 }
  }
end

require("nvim-lsp-installer").on_server_ready(function(server)
  local opts = {}

  if server.name == 'sumneko_lua' then
    opts.settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        }
      }
    }
  end

  server:setup(opts)
end)
----------------------------------
--     gitsigns
----------------------------------

require('gitsigns').setup()

----------------------------------
--     notify
----------------------------------

vim.notify = require("notify")

require("notify").setup({
  stages = "fade",
})

----------------------------------
--     Helper functions
----------------------------------

function telescope_into_dir(dir)
  require('telescope.builtin').find_files(require('telescope.themes').get_ivy({ search_dirs = { dir } }))
end

function create_new_note()
  local file_name = vim.fn.input('enter file name > ')
  vim.api.nvim_command(string.format(':e ~/notes/%s', file_name))
end

function open_file_in_repo()
  local root = vim.fn.finddir('.git/..', ';')
  telescope_into_dir(root)
end

function scratch_buffer(arg)
  local ftype = arg
  if ftype == nil then
    ftype = vim.fn.input('enter filetype > ')
  end

  if ftype == "" then
    return
  end

  vim.cmd ':vnew'
  vim.bo.bufhidden = 'hide'
  vim.bo.swapfile = false
  vim.bo.filetype = ftype
end

function open_config()
  if vim.fn.bufname() ~= "" then
    vim.api.nvim_command("tabnew ~/.config/nvim/init.lua")
    return
  end

  vim.api.nvim_command("edit ~/.config/nvim/init.lua")
end
