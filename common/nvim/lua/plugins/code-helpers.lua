local map = vim.api.nvim_set_keymap

return {
  { "tpope/vim-commentary" },
  { "tpope/vim-surround" },
  { "tpope/vim-fugitive" },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
      })
    end,
  },
  {
    "arjunmahishi/flow.nvim",
    config = function()
      require('flow').setup({
        output = {
          buffer = true,
        },
        filetype_cmd_map = {
          python = "python3 <<-EOF\n%s\nEOF",
        },
        custom_cmd_dir = "~/.flow_cmds"
        -- sql_configs = sql_configs,
      })

      map('v', '<leader>r', ':FlowRunSelected<CR>', {})
      map('n', '<leader>rr', ':FlowRunFile<CR>', {})
      map('n', '<leader>rt', ':FlowLauncher<CR>', {})
    end
  }
}
