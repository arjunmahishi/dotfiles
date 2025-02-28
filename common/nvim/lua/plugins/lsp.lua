SERVERS = {
  -- "gopls", "lua_ls", "jedi_language_server", "ts_ls", "tailwindcss",
  "gopls", "lua_ls", "jedi_language_server", "tailwindcss", "ts_ls",
}

function LspLineDiagnostic()
  local line = vim.fn.line(".")
  local diagnostics = vim.lsp.diagnostic.get_line_diagnostics(line)
  if #diagnostics == 0 then
    return
  end

  local diagnostic = diagnostics[1]
  local message = diagnostic.message

  if diagnostic.source then
    message = diagnostic.source .. ": " .. message
  end

  print(message)
end

local function lsp_hover_handler()
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
      border = "single",
      width = 80,
    }
  )
end

local function lsp_on_attach()
  vim.diagnostic.config({
    update_in_insert = true, -- this fixes the gopls issue where it has outdated diagnostics
    virtual_text = {
      prefix = '●',
    }
  })
end

local function gopls_on_attach(client, bufnr)
  lsp_on_attach()

  -- local watch_ignored = {
  --   "\\.bazel$",
  --   "_bazel$",
  --   "\\.cache$",
  --   "\\.git$",
  --   "c-deps$",
  -- }
  --
  -- for _, pattern in ipairs(watch_ignored) do
  --   vim.lsp.handlers["workspace/didChangeWatchedFiles"].add(pattern)
  -- end
end

local function gopls_on_new_config(new_config, new_root_dir)
  if new_root_dir == '/Users/armahishi/dev/work/db/cockroach' then
    new_config.settings.gopls.env = {
      GOPACKAGESDRIVER = './build/bazelutil/gopackagesdriver.sh'
    }
    new_config.settings.gopls.directoryFilters = {
      "-bazel-bin",
      "-bazel-out",
      "-bazel-testlogs",
      "-bazel-mypkg",
    }
  end
end

local function lsp_config()
  local lspconfig = require('lspconfig')

  local capabilities = vim.lsp.protocol.make_client_capabilities()

  for _, server in ipairs(SERVERS) do
    -- baseline LSP config. Applies to all servers
    local config = {
      capabilities = capabilities,
      on_attach = lsp_on_attach,
    }

    -- lua override
    if server == "lua_ls" then
      config.settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
        },
      }
    end

    -- gopls override - this attaches a custom on_new_config handler
    -- to add the GOPACKAGESDRIVER env variable when the go module's
    -- root directory is the cockroachDB repo
    if server == "gopls" then
      config.on_new_config = gopls_on_new_config
      config.on_attach = gopls_on_attach
    end

    -- tailwindcss override - skip unwanted filetypes
    if server == "tailwindcss" then
      config.filetypes = { "html", "css", "scss", "javascript", "typescript", "javascriptreact", "typescriptreact" }
    end

    if server == "ts_ls" then
      config.filetypes = { "typescript", "typescriptreact" }
    end

    lspconfig[server].setup(config)
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
    init = lsp_hover_handler,
    config = lsp_config,
    keys = {
      { "gd",         "<cmd>lua vim.lsp.buf.definition()<CR>" },
      { "K",          "<cmd>lua vim.lsp.buf.hover()<CR>" },
      { "gr",         "<cmd>lua vim.lsp.buf.rename()<CR>" },
      { "ga",         "<cmd>lua vim.lsp.buf.code_action()<CR>" },
      { "<leader>f",  "<cmd>lua vim.lsp.buf.formatting()<CR>" },
      { "<leader>rl", "<cmd>LspRestart<CR>" },
      { "<leader>e",  "<cmd>lua vim.diagnostic.open_float()<CR>" },
    },
  },

  -- stupid rust-analyzer doesn't work out of the box. We have to install the below plugin
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
  },
}
