local nvim_lsp = require('lspconfig')

require("mason").setup()
require("mason-lspconfig").setup()
require('lspsaga').setup({})

local map = vim.api.nvim_set_keymap

map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {})
map('n', 'K', '<cmd>Lspsaga hover_doc<CR>', {})
map('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', {})
map('n', 'gR', '<cmd>lua vim.lsp.buf.references()<CR>', {})
map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {})
map('n', '<leader>rl', ':LspRestart<CR>', {})

local capabilities = require('cmp_nvim_lsp').default_capabilities(
  vim.lsp.protocol.make_client_capabilities())

local servers = {
  'gopls', 'lua_ls', 'vimls', 'tsserver', 'jedi_language_server', 'eslint',
}

-- iterate over each of the servers and setup each of them
for _, lsp in ipairs(servers) do
  if lsp == 'gopls' then
    nvim_lsp.gopls.setup {
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 150
      },
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
        },
      },
    }

  elseif lsp == 'lua_ls' then
    nvim_lsp.lua_ls.setup {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
        },
      },
    }
  else
    -- default setup for all other servers
    nvim_lsp[lsp].setup {
      capabilities = capabilities,
      flags = { debounce_text_changes = 150 }
    }
  end
end

