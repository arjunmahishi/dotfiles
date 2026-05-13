vim.g.mapleader = " "

------------------------------------
--       Setup lazy.nvim
------------------------------------

local username = string.gsub(vim.fn.system("whoami"), "\n", "")
local lazypath = string.format("/Users/%s/.nvim-plugins/lazy.nvim", username)
if not vim.uv.fs_stat(lazypath) then
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
	root = string.format("/Users/%s/.nvim-plugins", username),
	change_detection = {
		notify = false,
	},
})

------------------------------------
--        Custome key bindings
------------------------------------

vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "vv", ":vsplit<CR>")
vim.keymap.set("n", "tt", ":tabnew<CR>")
vim.keymap.set("n", "<C-s>", ":source ~/.config/nvim/init.lua<CR>")
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("n", "<C-l>", ":nohlsearch<cr>")
vim.keymap.set("n", "<leader>fd", function() OpenFilesInRepo() end)

-- since space is used as the supream leader, make sure that is doesn't do anything
-- else. Because no one should have that much power
vim.keymap.set("n", "<SPACE>", "<Nop>", { noremap = true })
vim.keymap.set("v", "<SPACE>", "<Nop>", { noremap = true })

-- switching between panes
vim.keymap.set("n", "<leader>w", "<c-w><c-w>", { noremap = true })
vim.keymap.set("n", "<leader>h", "<c-w>h", { noremap = true })
vim.keymap.set("n", "<leader>j", "<c-w>j", { noremap = true })
vim.keymap.set("n", "<leader>k", "<c-w>k", { noremap = true })
vim.keymap.set("n", "<leader>l", "<c-w>l", { noremap = true })

-- BarBar
vim.keymap.set("n", "<C-j>", ":BufferPrevious<CR>")
vim.keymap.set("n", "<C-k>", ":BufferNext<CR>")
vim.keymap.set("n", "<C-x>", ":BufferClose<CR>")

-- terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true })

-- float term
vim.keymap.set("n", "gt", ":FloatermToggle<cr>", { noremap = true })

-- formatting
vim.api.nvim_create_autocmd("FileType", {
	pattern = "json",
	callback = function()
		vim.keymap.set("n", "<leader>f", ":%!jq '.' %<CR>", { buffer = true })
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "hcl",
	callback = function()
		vim.keymap.set("n", "<leader>f", ":%!hclfmt %<CR>", { buffer = true })
	end,
})

-- quickfix
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
vim.keymap.set("n", "<leader>]", ":cnext<cr>", { noremap = true })
vim.keymap.set("n", "<leader>[", ":cprevious<cr>", { noremap = true })

-- Gdiff
vim.keymap.set("n", "g2", ":diffget //2 | diffupdate <CR>")
vim.keymap.set("n", "g3", ":diffget //3 | diffupdate <CR>")

------------------------------------
--        Helper functions
------------------------------------

local function replace_vars(str, vars)
	for k, v in pairs(vars) do
		str = string.gsub(str, string.format("${%s}", k), v)
	end
	return str
end

function StatusLine()
	local git_branch = vim.fn.system("git branch --show-current 2>/dev/null")
	git_branch = string.gsub(git_branch, "\n", "")

	if git_branch ~= "" then
		git_branch = string.format(" %s · ", git_branch)
	end

	vim.g.modes = {
		["n"] = "NORMAL",
		["v"] = "VISUAL",
		["V"] = "V-LINE",
		[""] = "V-BLOCK",
		["i"] = "INSERT",
		["c"] = "COMMAND",
		["t"] = "TERMINAL",
	}

	-- Define a global function for LSP status
	_G.GetLspStatus = function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients > 0 then
			local names = {}
			for _, client in pairs(clients) do
				table.insert(names, client.name)
			end
			return table.concat(names, ",") .. " ✔"
		else
			return "LSP ✖"
		end
	end

	return replace_vars(
		"%{get(g:modes, mode())} · %f %r %m · %{v:lua.GetLspStatus()} %=%l:%c · %p%% · ${git_branch}%{&filetype} ",
		{
			git_branch = git_branch,
		}
	)
end

function TelescopeIntoDir(dir)
	require("telescope.builtin").find_files(require("telescope.themes").get_ivy({ search_dirs = { dir } }))
end

function OpenFilesInRepo()
	local root = vim.fn.finddir(".git/..", ";")
	TelescopeIntoDir(root)
end

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
vim.opt.colorcolumn = "121"
vim.opt.lazyredraw = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.mouse = "a"
vim.opt.encoding = "utf8"
vim.opt.guifont = "Fira Code Nerd"
vim.opt.showmode = false
vim.opt.scrolloff = 10
vim.opt.inccommand = "split"
vim.opt.wrap = false
vim.opt.dictionary = "/usr/share/dict/words"
vim.opt.signcolumn = "yes:1"
vim.opt.statusline = StatusLine()

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank()
	end,
})

-- make backgroud transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
