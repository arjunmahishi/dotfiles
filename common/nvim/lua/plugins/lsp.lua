SERVERS = { "gopls", "lua_ls" }

local function lsp_setup()
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
      border = "single",
      width = 80,
    }
  )
end

local function lsp_config()
  local lspconfig = require('lspconfig')

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  for _, server in ipairs(SERVERS) do
    lspconfig[server].setup {
      capabilities = capabilities,
    }
  end
end

return {
    -- Mason plugin for managing LSP servers and other tools
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    -- Mason LSPconfig to bridge between Mason and nvim-lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = SERVERS, -- Ensure gopls is installed
            })
        end,
    },

    -- LSP configuration
    {
        "neovim/nvim-lspconfig",
        init = lsp_setup,
        config = lsp_config,
        keys = {
            { "gd", "<cmd>lua vim.lsp.buf.definition()<CR>" },
            { "K", "<cmd>lua vim.lsp.buf.hover()<CR>" },
            { "gr", "<cmd>lua vim.lsp.buf.rename()<CR>" },
            { "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>" },
            { "<leader>rl", "<cmd>LspRestart<CR>" },
        },
    },
}
