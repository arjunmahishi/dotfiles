return {
  {
    "romgrk/barbar.nvim",
    lazy = true,
    event = "BufRead",
  },
  {
    "nvim-tree/nvim-tree.lua",
    keys = {
      { "<leader>o", "<cmd>NvimTreeToggle<CR>" },
      { "<leader>O", "<cmd>NvimTreeFindFile<CR>" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()

      -- close nvim-tree when it's the only window left
      vim.cmd([[
        augroup nvim_tree_close
          autocmd!
          autocmd WinEnter * if winnr('$') == 1 && &filetype == 'NvimTree' | q | endif
        augroup END
      ]])
    end,
  },
}
