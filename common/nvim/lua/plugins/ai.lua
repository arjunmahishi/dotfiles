return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			-- model = "gpt-4o",
			-- model = "gemini-2.0-flash-001",
			model = "claude-4.5-sonnet",
			-- model = "claude-4.5-opus",
			contexts = {
				jeeves = {
					resolve = function()
						return require("jeeves").collect_context()
					end,
				},
			},
		},
		config = function(_, opts)
			require("CopilotChat").setup(opts)
			local model = require("CopilotChat").config.model
			local chat = function()
				vim.ui.input({ prompt = model .. ": " }, function(input)
					if input then
						vim.cmd("CopilotChat " .. input)
					end
				end)
			end

			vim.keymap.set("n", "<leader>i", chat, { desc = "Ask Copilot" })
			vim.keymap.set("v", "<leader>i", chat, { desc = "Ask Copilot" })
			vim.keymap.set("n", "<leader>c", "<cmd>CopilotChat<CR>", { desc = "Copilot Chat" })
			vim.keymap.set("v", "<leader>c", "<cmd>CopilotChat<CR>", { desc = "Copilot Chat" })
		end,
	},
	{
		"angles-n-daemons/jeeves",
		keys = {
			{
				mode = { "v" },
				"M", -- hit M in visual mode to add the selection to your context.
				function()
					require("jeeves").add_selection()
				end,
			},
			{
				mode = { "n" },
				"M", -- hit M in normal mode to remove the selection under your cursor.
				function()
					require("jeeves").remove_selections_under_cursor()
				end,
			},
			{
				"<leader>jc",
				function()
					require("jeeves").clear()
				end,
			},
		},
	},
	-- {
	-- 	"coder/claudecode.nvim",
	-- 	dependencies = { "folke/snacks.nvim" },
	-- 	config = true,
	-- 	lazy = false, -- load on startup
	-- 	opts = {
	-- 		terminal = {
	-- 			provider = "none",
	-- 		},
	-- 	},
	-- 	keys = {
	-- 		{ "<leader>a", nil, desc = "AI/Claude Code" },
	-- 		{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
	-- 		{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
	-- 		{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
	-- 		{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
	-- 		{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
	-- 		{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
	-- 		{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
	-- 		{
	-- 			"<leader>as",
	-- 			"<cmd>ClaudeCodeTreeAdd<cr>",
	-- 			desc = "Add file",
	-- 			ft = { "NvimTree", "neo-tree", "oil" },
	-- 		},
	-- 		-- Diff management
	-- 		{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
	-- 		{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
	-- 	},
	-- },
	{
		"NickvanDyke/opencode.nvim",
		dependencies = {
			-- Recommended for `ask()` and `select()`.
			-- Required for `snacks` provider.
			---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
			{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
		},
		config = function()
			vim.g.opencode_opts = {
				-- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
			}

			-- Required for `opts.events.reload`.
			vim.o.autoread = true

			-- Recommended/example keymaps.
			vim.keymap.set({ "n", "x" }, "<C-a>", function()
				require("opencode").ask("@this: ", { submit = true })
			end, { desc = "Ask opencode…" })
			vim.keymap.set({ "n", "x" }, "<C-x>", function()
				require("opencode").select()
			end, { desc = "Execute opencode action…" })
			vim.keymap.set({ "n", "t" }, "<C-.>", function()
				require("opencode").toggle()
			end, { desc = "Toggle opencode" })

			vim.keymap.set({ "n", "x" }, "go", function()
				return require("opencode").operator("@this ")
			end, { desc = "Add range to opencode", expr = true })
			vim.keymap.set("n", "goo", function()
				return require("opencode").operator("@this ") .. "_"
			end, { desc = "Add line to opencode", expr = true })

			-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
			vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
			vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
		end,
	},
}
