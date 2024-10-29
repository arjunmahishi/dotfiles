return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        -- current_line_blame = true,
      })
    end,
  },
  {
    "jbyuki/venn.nvim",
    config = function()
      vim.api.nvim_set_keymap("v", "<leader>b", ":VBox<CR>", { noremap = true })
    end,
  },
  { "tpope/vim-fugitive" },
  { "ruanyl/vim-gh-line" },
}
