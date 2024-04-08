local map = vim.api.nvim_set_keymap
local username = string.gsub(vim.fn.system('whoami'), '\n', '')

return {
  { "tpope/vim-commentary" },
  { "tpope/vim-surround" },
  { "tpope/vim-fugitive" },
  { "jiangmiao/auto-pairs" },
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
        filetype_cmd_map = {
          python = "python3 <<-EOF\n%s\nEOF",
        },
        custom_cmd_dir = string.format("/Users/%s/.flow_cmds", username)
        -- sql_configs = sql_configs,
      })

      map('v', '<leader>r', ':FlowRunSelected<CR>', {})
      map('n', '<leader>rr', ':FlowRunFile<CR>', {})
      map('n', '<leader>rt', ':FlowLauncher<CR>', {})
      map('n', '<leader>rp', ':FlowRunLastCmd<CR>', {})
      map('n', '<leader>ro', ':FlowLastOutput<CR>', {})
      map('n', '<leader>rq', ':FlowRunQuickCmd<CR>', {})
    end
  },
  { 'bennypowers/splitjoin.nvim',
    lazy = true,
    keys = {
      { 'gj', function() require'splitjoin'.join() end, desc = 'Join the object under cursor' },
      { 'g,', function() require'splitjoin'.split() end, desc = 'Split the object under cursor' },
    },
  },
  {
    "leoluz/nvim-dap-go",
    dependencies = {
      { "mfussenegger/nvim-dap" },
    },
    config = function ()
      require('dap-go').setup()

      map('n', '<leader>dc', ':lua require("dap").continue()<CR>', {})
      map('n', '<leader>db', ':lua require("dap").toggle_breakpoint()<CR>', {})
      map('n', '<leader>dr', ':lua require("dap").repl.open()<CR>', {})
      map('n', '<leader>ds', ':lua require("dap").step_over()<CR>', {})
      map('n', '<leader>di', ':lua require("dap").step_into()<CR>', {})
      map('n', '<leader>do', ':lua require("dap").step_out()<CR>', {})
    end,
  },
  -- {
  --   "ray-x/go.nvim",
  --   dependencies = {
  --     { "mfussenegger/nvim-dap" },
  --   },
  --   config = function ()
  --     require("go").setup()
  --   end,
  --   event = {"CmdlineEnter"},
  --   ft = {"go", 'gomod'},
  -- }
}
