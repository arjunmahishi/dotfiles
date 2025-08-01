return {
	{ "github/copilot.vim" },
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = {
			model = "gpt-4o",
			-- model = "gemini-2.0-flash-001",
			-- model = "claude-3.7-sonnet",
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
	{
		"saghen/blink.cmp",
		version = "*",
		config = function()
			require("blink.cmp").setup({
				signature = { enabled = true },
				appearance = {
					use_nvim_cmp_as_default = false,
					nerd_font_variant = "normal",
				},
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
					providers = {
						cmdline = {
							min_keyword_length = 2,
						},
					},
				},
				cmdline = {
					enabled = true,
					completion = { menu = { auto_show = true } },
					keymap = {
						["<CR>"] = { "accept_and_enter", "fallback" },
					},
				},
				completion = {
					menu = {
						border = "rounded",
						scrolloff = 1,
						scrollbar = true,
						draw = {
							columns = {
								{ "kind_icon" },
								{ "label", "label_description", gap = 1 },
								{ "source_name" },
							},
						},
					},
				},
			})
		end,
	},
}
