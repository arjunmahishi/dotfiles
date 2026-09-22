return {
	{
		"saurabh-hirani/review.nvim",
		dependencies = {
			"esmuellert/codediff.nvim",
			"MunifTanjim/nui.nvim",
		},
		cmd = { "Review" },
		keys = {
			{ "<leader>Ro", "<cmd>Review<cr>", desc = "Review changes" },
			{ "<leader>Rc", "<cmd>Review commits<cr>", desc = "Review commits" },
			{ "<leader>Ra", "<cmd>Review annotate<cr>", desc = "Add review comment" },
			{ "<leader>Ra", ":'<,'>Review annotate<cr>", mode = "v", desc = "Add review comment" },
			{ "<leader>Rl", "<cmd>Review list<cr>", desc = "List review comments" },
			{ "<leader>Re", "<cmd>Review export<cr>", desc = "Export review comments" },
			{ "<leader>Rt", "<cmd>Review tmux<cr>", desc = "Send review to tmux pane" },
			{ "<leader>Rm", "<cmd>Review marks<cr>", desc = "Toggle review marks" },
		},
		opts = {
			comment_types = {
				fix = { key = "f", name = "Fix", icon = "!", hl = "DiagnosticError" },
				question = { key = "q", name = "Question", icon = "?", hl = "DiagnosticWarn" },
				note = { key = "n", name = "Note", icon = "*", hl = "DiagnosticInfo" },
			},
			popup = {
				type_order = { "fix", "question", "note" },
				default_type = "fix",
			},
			-- Avoid conflicting with the file-comment mapping (<localleader>cf).
			keymaps = { add_file_comment = "<localleader>cF" },
			export = {
				path_style = "absolute",
				header = "Address the FIX comments and answer the QUESTION comments below. Make the smallest reasonable changes and run relevant tests.",
				types = { "fix", "question" },
				order = "categorized",
				category_order = "config",
			},
			codediff = { restore_edit_on_close = true },
			tmux = { send_enter = false },
		},
	},
}
