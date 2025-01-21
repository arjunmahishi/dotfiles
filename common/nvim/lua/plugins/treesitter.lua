return {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = { "go", "lua", "python", "typescript", "javascript", "json", "yaml", "html", "css", "bash", "query", "vim", "vimdoc", "luadoc" },
      })
    end,
  },
}
