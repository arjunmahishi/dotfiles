local map = vim.api.nvim_set_keymap
local username = string.gsub(vim.fn.system('whoami'), '\n', '')

return {
  { "tpope/vim-commentary" },
  { "tpope/vim-surround" },
  { "jiangmiao/auto-pairs" },
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
  {
    'bennypowers/splitjoin.nvim',
    lazy = true,
    keys = {
      { 'gj', function() require 'splitjoin'.join() end,  desc = 'Join the object under cursor' },
      { 'g,', function() require 'splitjoin'.split() end, desc = 'Split the object under cursor' },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "nvim-neotest/nvim-nio" },
      { "leoluz/nvim-dap-go" },
      { "rcarriga/nvim-dap-ui" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dapui.setup({
        layouts = { {
          elements = { {
            id = "scopes",
            size = 0.5
          }, {
            id = "repl",
            size = 0.5
          } },
          position = "bottom",
          size = 10
        } },
      })

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      require('dap-go').setup()
      map('n', '<leader>dc', ':lua require("dap").continue()<CR>', {})
      map('n', '<leader>db', ':lua require("dap").toggle_breakpoint()<CR>', {})
      map('n', '<leader>dr', ':lua require("dap").repl.open()<CR>', {})
      map('n', '<leader>ds', ':lua require("dap").step_over()<CR>', {})
      map('n', '<leader>di', ':lua require("dap").step_into()<CR>', {})
      map('n', '<leader>do', ':lua require("dap").step_out()<CR>', {})
      map('n', '<leader>dx', ':lua require("dap").close()<CR>', {})
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
