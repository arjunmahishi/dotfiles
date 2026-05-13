local username = string.gsub(vim.fn.system('whoami'), '\n', '')

-- A function to cycle through nodes of a specific type. This uses treesitter's
-- AST to find all the nodes.
local function jump_to_node(target_node_type, direction)
  -- Collect all target nodes
  local parser = vim.treesitter.get_parser(0)
  if not parser then return end
  local root = parser:parse()[1]:root()
  local target_nodes = {}
  for node in root:iter_children() do
    if node:type() == target_node_type then
      table.insert(target_nodes, { row = node:start() + 1, col = select(2, node:start()) })
    end
  end

  -- Exit if no target found
  if #target_nodes == 0 then return end

  -- find the nearest target node
  local cur_pos = vim.api.nvim_win_get_cursor(0)
  local nearest_node = 1
  for i, pos in ipairs(target_nodes) do
    if cur_pos[1] >= pos.row then
      nearest_node = i
    end
  end

  -- move to the next/prev node
  local incr = direction == "next" and 1 or -1
  if nearest_node + incr > #target_nodes then
    return vim.api.nvim_win_set_cursor(0, { target_nodes[1].row, target_nodes[1].col })
  end

  if nearest_node + incr < 1 then
    return vim.api.nvim_win_set_cursor(0, { target_nodes[#target_nodes].row, target_nodes[#target_nodes].col })
  end

  return vim.api.nvim_win_set_cursor(0,
    { target_nodes[nearest_node + incr].row, target_nodes[nearest_node + incr].col })
end

-- map the function navigation keys
vim.keymap.set('n', ']f', function() jump_to_node("function_declaration", "next") end)
vim.keymap.set('n', '[f', function() jump_to_node("function_declaration", "prev") end)
vim.keymap.set('n', ']v', function() jump_to_node("variable_declaration", "next") end)
vim.keymap.set('n', '[v', function() jump_to_node("variable_declaration", "prev") end)

return {
  {
    "tpope/vim-commentary",
    config = function()
      -- setup commentstring for terraform
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "terraform",
        callback = function()
          vim.bo.commentstring = "# %s"
        end,
      })
    end,
  },
  { "tpope/vim-surround" },
  { "jiangmiao/auto-pairs" },
  {
    "arjunmahishi/flow.nvim",
    config = function()
      require('flow').setup({
        filetype_cmd_map = {
          python = "python3 <<-EOF\n%s\nEOF",
          rust = "cargo run -q",
        },
        custom_cmd_dir = string.format("/Users/%s/.flow_cmds", username)
      })

      vim.keymap.set('v', '<leader>r', ':FlowRunSelected<CR>')
      vim.keymap.set('n', '<leader>rr', ':FlowRunFile<CR>')
      vim.keymap.set('n', '<leader>rt', ':Telescope flow theme=ivy<CR>')
      vim.keymap.set('n', '<leader>rp', ':FlowRunLastCmd<CR>')
      vim.keymap.set('n', '<leader>ro', ':FlowLastOutput<CR>')
      vim.keymap.set('n', '<leader>rq', ':FlowRunQuickCmd<CR>')
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
      vim.keymap.set('n', '<leader>dc', function() dap.continue() end)
      vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end)
      vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
      vim.keymap.set('n', '<leader>ds', function() dap.step_over() end)
      vim.keymap.set('n', '<leader>di', function() dap.step_into() end)
      vim.keymap.set('n', '<leader>do', function() dap.step_out() end)
      vim.keymap.set('n', '<leader>dx', function() dap.close() end)
    end,
  },
}
