return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = { "crlfmt", "stylua" },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters = {
        crlfmt = {
          command = "crlfmt",
        },
      },
      formatters_by_ft = {
        go = { "crlfmt" },
        lua = { "stylua" },
      },
    },
  },
}
