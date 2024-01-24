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
Plug('nvim-telescope/telescope-github.nvim')
Plug('nvim-telescope/telescope-live-grep-args.nvim')

-- treesitter
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate'})

Plug('nvim-tree/nvim-tree.lua')
Plug('tpope/vim-surround')
Plug('jiangmiao/auto-pairs')
Plug('lewis6991/gitsigns.nvim')
Plug('tomtom/tcomment_vim')
Plug('tpope/vim-fugitive')
Plug('romgrk/barbar.nvim')
Plug('buoto/gotests-vim')
Plug('AndrewRadev/splitjoin.vim')
Plug('nvim-lualine/lualine.nvim')
Plug('voldikss/vim-floaterm')
Plug('iamcco/markdown-preview.nvim', { ['do'] = 'cd app && yarn install' })
Plug('arjunmahishi/flow.nvim')
Plug('arjunmahishi/k8s.nvim')
Plug('rcarriga/nvim-notify')
Plug('ruanyl/vim-gh-line')
Plug('jbyuki/venn.nvim')
Plug('github/copilot.vim')

-- LSP
Plug('neovim/nvim-lspconfig')
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('nvimdev/lspsaga.nvim')

-- debugger
Plug('mfussenegger/nvim-dap')
Plug('rcarriga/nvim-dap-ui')
Plug('theHamsta/nvim-dap-virtual-text')
Plug('nvim-telescope/telescope-dap.nvim')
Plug('leoluz/nvim-dap-go')

-- auto completion
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-nvim-lua')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('L3MON4D3/LuaSnip')
Plug('benfowler/telescope-luasnip.nvim')

-- colorscheme
Plug('lifepillar/vim-gruvbox8')
Plug('ryanoasis/vim-devicons')
Plug('nvim-tree/nvim-web-devicons')
Plug('folke/tokyonight.nvim')

vim.call('plug#end')

----------------------------------
--        basic settings
----------------------------------

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd 'syntax enable'

vim.opt.termguicolors = true
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
vim.opt.inccommand = 'split'
vim.opt.wrap = false
vim.opt.dictionary = '/usr/share/dict/words'
vim.opt.signcolumn = 'yes:1'

vim.cmd [[
  au TextYankPost * silent! lua vim.highlight.on_yank()
]]


---------------------------------
--     colorscheme
----------------------------------

require('tokyonight').setup({
  on_colors = function(colors)
    colors.gitSigns = {
      add = colors.green,
      change = colors.orange,
      delete = colors.red,
      conflict = '#e5c07b',
    }
  end
})

vim.cmd 'colorscheme tokyonight-night'

---------------------------------
--     custom key mapping
----------------------------------

vim.g.mapleader = ' '

local map = vim.api.nvim_set_keymap
local noremap = { noremap = true }

map('i', 'jj', '<Esc>', {})
map('n', 'vv', ':vsplit<CR>', {})
map('n', 'tt', ':tabnew<CR>', {})
map('n', '<C-s>', ':source ~/.config/nvim/init.lua<CR>', {})
map('v', '<leader>y', '"+y', {})
map('n', '<leader>p', '"+p', {})
map('n', '<C-l>', ':nohlsearch<cr>', {})
map('n', '<leader>fd', ':lua OpenFilesInRepo()<cr>', {})

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

vim.cmd([[
  augroup GoAutocmds
    autocmd!
    autocmd BufWritePost *.go lua vim.api.nvim_command('silent! !gofmt -w %')
    autocmd BufWritePost *.go lua vim.api.nvim_command('silent! !goimports -w %')
  augroup END
]])

-- Gdiff
map('n', 'g2', ':diffget //2 | diffupdate <CR>', {})
map('n', 'g3', ':diffget //3 | diffupdate <CR>', {})

----------------------------------
--     custom commands
----------------------------------

local function command(name, cmd)
  vim.cmd(string.format("command! -nargs=* %s %s", name, cmd))
end

command('Config', ':lua OpenConfig()')
command('Notes', ':lua TelescopeIntoDir("~/notes")')
command('NewNote', ':lua CreateNewNote()')
command('Scratch', ':lua ScratchBuffer(<f-args>)')

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
    lualine_x = {'encoding', 'filetype', {
      'diagnostics',
      sources={'nvim_diagnostic'},
    }},
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
--    nvim-tree
----------------------------------

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

map('n', '<leader>o', ':NvimTreeToggle<CR>', {})
map('n', '<leader>O', ':NvimTreeFindFileToggle<CR>', {})

-- close nvim-tree when no other window is open
vim.cmd [[
  augroup NvimTree
    autocmd!
    autocmd WinEnter * if (winnr("$") == 1 && &filetype == "NvimTree") | q | endif
  augroup END
]]

----------------------------------
--    multi select
----------------------------------

vim.g.VM_maps = { ['Find Under'] = '<C-d>', ['Find Subword Under'] = '<C-d>' }

----------------------------------
--   telescope
----------------------------------

require('config.telescope')

----------------------------------
--   treesitter
----------------------------------

-- TODO: figure this shit out
require'nvim-treesitter.configs'.setup {
  -- ensure_installed = "maintained",
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
--   flow.nvim
----------------------------------

-- local sql_configs = require('flow.util').read_sql_config('/Users/arjunmahishi/.db_config.json')

require('flow').setup {
  output = {
    buffer = true,
    -- size = 60,
  },
  filetype_cmd_map = {
    python = "python3 <<-EOF\n%s\nEOF",
  },
  custom_cmd_dir = "~/.flow_cmds"
  -- sql_configs = sql_configs,
}

map('v', '<leader>r', ':FlowRunSelected<CR>', {})
map('n', '<leader>rr', ':FlowRunFile<CR>', {})
map('n', '<leader>rt', ':FlowLauncher<CR>', {})

-- set custom commands
map('n', '<leader>R1', ':FlowSetCustomCmd 1<CR>', {})
map('n', '<leader>R2', ':FlowSetCustomCmd 2<CR>', {})
map('n', '<leader>R3', ':FlowSetCustomCmd 3<CR>', {})

-- run custom commands
map('n', '<leader>r1', ':FlowRunCustomCmd 1<CR>', {})
map('n', '<leader>r2', ':FlowRunCustomCmd 2<CR>', {})
map('n', '<leader>r3', ':FlowRunCustomCmd 3<CR>', {})
map('n', '<leader>rp', ':FlowRunLastCmd<CR>', {})
map('n', '<leader>ro', ':FlowLastOutput<CR>', {})

----------------------------------
--   luasnip
----------------------------------

require("luasnip.loaders.from_snipmate").load()

----------------------------------
--   nvim-cmp
----------------------------------

local cmp = require('cmp')
local luasnip = require('luasnip')

local cmp_icons = {
  Text = " ", Method = "ƒ", Function = "ƒ", Constructor = " ", Field = "",
  Variable = "", Class = " ", Interface = " ", Module = " ", Property = " ",
  Unit = " ", Value = " ", Enum = " ", Keyword = " ", Snippet = " ",
  Color = " ", File = " ", Reference = " ", Folder = " ", EnumMember = " ",
  Constant = " ", Struct = " ", Event = " ", Operator = " ", TypeParameter = "",
}

local mapping = {
  ['<CR>'] = function(fallback)
    if cmp.get_selected_entry() then
      cmp.confirm()
      return
    end

    fallback()
  end,
  ['<C-SPACE>'] = cmp.mapping.complete(),
  ['<C-k>'] = function(fallback)
    if luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
      return
    end
    fallback()
  end,
  ["<C-n>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
      return
    end

    fallback()
  end, { "i", "s", "c" }),
  ["<C-p>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
      return
    end

    fallback()
  end, { "i", "s", "c" }),
}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
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
  },
  preselect = cmp.PreselectMode.None,
  window = {
    completion = {
      border = 'rounded',
    },
    documentation = {
      border = 'rounded',
    },
  },
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

require("config.lsp")

----------------------------------
--     gitsigns
----------------------------------

require('gitsigns').setup({
  current_line_blame = true,
})

----------------------------------
--     notify
----------------------------------

vim.notify = require("notify")

require("notify").setup({
  stages = "fade",
})

----------------------------------
--     venn
----------------------------------

map('v', '<leader>b', ':VBox<CR>', {})
map('v', '<leader>f', ':VsFill<CR>', {})

----------------------------------
--     k8s.nvim
----------------------------------

require('k8s').setup {
  kube_config_dir = '/tmp/kubeconfig'
}

map('n', '<leader>kc', ':K8sKubeConfig<CR>', {})
map('n', '<leader>kn', ':K8sNamespaces<CR>', {})

----------------------------------
--     debugger
----------------------------------

require("config.debuggers")

----------------------------------
--     Helper functions
----------------------------------

function TelescopeIntoDir(dir)
  require('telescope.builtin').find_files(require('telescope.themes').get_ivy({ search_dirs = { dir } }))
end

function CreateNewNote()
  local file_name = vim.fn.input('enter file name > ')
  vim.api.nvim_command(string.format(':e ~/notes/%s', file_name))
end

function OpenFilesInRepo()
  local root = vim.fn.finddir('.git/..', ';')
  TelescopeIntoDir(root)
end

function ScratchBuffer(arg)
  local ftype = arg
  if ftype == nil then
    ftype = vim.fn.input('enter filetype > ')
  end

  if ftype == "" then
    return
  end

  vim.cmd ':vsplit'
  vim.bo.bufhidden = 'hide'
  vim.bo.swapfile = false
  vim.bo.filetype = ftype
end

function OpenConfig()
  if vim.fn.bufname() ~= "" then
    vim.api.nvim_command("tabnew ~/.config/nvim/init.lua")
    return
  end

  vim.api.nvim_command("edit ~/.config/nvim/init.lua")
end
