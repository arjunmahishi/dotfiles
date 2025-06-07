vim.lsp.enable({
	"gopls",
	"lua_ls",
	"jedi_language_server",
	"tailwindcss",
	"ts_ls",
})

vim.diagnostic.config({
	update_in_insert = true, -- this fixes the gopls issue where it has outdated diagnostics
	virtual_text = {
		prefix = "●",
	},
	float = {
		border = "rounded",
		source = true,
	},
})

local opts = { buffer = buffer }
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
vim.keymap.set("n", "gr", vim.lsp.buf.rename, opts)
vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
}
