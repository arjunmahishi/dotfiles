vim.g.mapleader = ' '

------------------------------------
--       Setup lazy.nvim
------------------------------------

local lazypath = "/Users/armahishi/.nvim-plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  root = "/Users/armahishi/.nvim-plugins",
	change_detection = {
		notify = false,
	},
})

------------------------------------
--        Custome key bindings
------------------------------------


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

------------------------------------
--        Global settings
------------------------------------

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

vim.cmd [[colorscheme tokyonight-night]]

------------------------------------
--        Helper functions
------------------------------------

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

