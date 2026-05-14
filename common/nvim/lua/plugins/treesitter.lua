return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})
      require("nvim-treesitter").install({
        "go", "gomod", "lua", "python", "typescript", "javascript",
        "json", "yaml", "html", "css", "bash", "query", "vim",
        "vimdoc", "luadoc", "diff", "hcl", "terraform", "markdown",
        "markdown_inline", "ini", "scheme",
      })

      -- Treesitter highlighting and indentation
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "go", "gomod", "lua", "python", "typescript", "javascript",
          "json", "yaml", "html", "css", "bash", "hcl", "terraform",
          "markdown", "vim", "vimdoc", "diff", "query",
        },
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
