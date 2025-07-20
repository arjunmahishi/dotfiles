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
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "ErrorMsg",
			[vim.diagnostic.severity.WARN] = "WarningMsg",
		},
	},
})

-- Set diagnostic highlight groups with gruvbox material colors
vim.cmd([[highlight DiagnosticVirtualTextError guifg=Red]]) -- bright red
vim.cmd([[highlight DiagnosticVirtualTextWarn guifg=Orange]]) -- bright orange

-- Function to restart LSP server
local function restart_lsp()
	-- Store the list of servers currently enabled
	local servers = {}
	for _, client in ipairs(vim.lsp.get_active_clients()) do
		if client.name ~= "GitHub Copilot" then
			table.insert(servers, client.name)
			vim.lsp.stop_client(client.id)
		end
	end
	print("Stopped LSP servers: " .. table.concat(servers, ", "))

	vim.defer_fn(function()
		-- Re-enable the servers
		print(vim.inspect(servers))
		vim.lsp.enable(servers)
		print("Restarted LSP servers: " .. table.concat(servers, ", "))
	end, 500) -- 500ms delay
end

local opts = {}
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
vim.keymap.set("n", "gr", vim.lsp.buf.rename, opts)
vim.keymap.set("n", "ga", vim.lsp.buf.code_action, opts)
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "<leader>rl", restart_lsp, { desc = "Restart LSP servers" })
vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)

return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
}
