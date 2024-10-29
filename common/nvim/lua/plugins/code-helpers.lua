local map = vim.api.nvim_set_keymap
local username = string.gsub(vim.fn.system('whoami'), '\n', '')

-- A function to cycle through nodes of a specific type. This uses treesitter's
-- AST to find all the nodes.
local function jump_to_node(target_node_type, direction)
  local parser = vim.treesitter.get_parser(0)
  local root = parser:parse()[1]:root()
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local target_pos = nil

  -- Collect all target nodes
  local target_nodes = {}
  for node in root:iter_children() do
    if node:type() == target_node_type then
      table.insert(target_nodes, { row = node:start() + 1, col = select(2, node:start()) })
    end
  end

  -- Exit if no target found
  if #target_nodes == 0 then return end

  -- Find the target based on direction
  for _, pos in ipairs(target_nodes) do
    if (direction == "next" and (pos.row > current_pos[1] or (pos.row == current_pos[1] and pos.col > current_pos[2]))) or
        (direction == "prev" and (pos.row < current_pos[1] or (pos.row == current_pos[1] and pos.col < current_pos[2]))) then
      target_pos = pos
      break
    end
  end

  -- Wrap around if no target found in the specified direction
  target_pos = target_pos or (direction == "next" and target_nodes[1] or target_nodes[#target_nodes])

  -- Move to the target position
  vim.api.nvim_win_set_cursor(0, { target_pos.row, target_pos.col })
end

-- map the function navigation keys
map('n', ']f', '', {
  callback = function()
    jump_to_node("function_declaration", "next")
  end
})

map('n', '[f', '', {
  callback = function()
    jump_to_node("function_declaration", "prev")
  end
})

map('n', ']v', '', {
  callback = function()
    jump_to_node("variable_declaration", "next")
  end
})

map('n', '[v', '', {
  callback = function()
    jump_to_node("variable_declaration", "prev")
  end
})

return {
  {
    "tpope/vim-commentary",
    config = function()
      -- setup commentstring for terraform
      vim.api.nvim_command("autocmd FileType terraform setlocal commentstring=#\\ %s")
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
        },
        custom_cmd_dir = string.format("/Users/%s/.flow_cmds", username)
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
}
