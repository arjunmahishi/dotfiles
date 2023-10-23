require('dapui').setup()
require('dap-go').setup()
require('telescope').load_extension('dap')
-- require('nvim-dap-virtual-text').setup()

-- keymaps
local map = vim.api.nvim_set_keymap
map('n', '<leader>dc', ':lua require("dap").continue()<CR>', {})
map('n', '<leader>db', ':lua require("dap").toggle_breakpoint()<CR>', {})
map('n', '<leader>dr', ':lua require("dap").repl.open()<CR>', {})
map('n', '<leader>dn', ':lua require("dap").step_over()<CR>', {})
map('n', '<leader>td', ':Telescope dap commands<CR>', {})

-- dap-go
map('n', '<leader>dt', ':lua require("dap-go").debug_test()<CR>', {})

-- dapui callbacks
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- breakpoint icons
vim.fn.sign_define('DapBreakpoint', {
  text='♟', texthl='DapUIBreakpointsInfo', numhl='DapUIBreakpointsInfo',
})
vim.fn.sign_define('DapBreakpointCondition', { 
  text='♞', texthl='DapUIBreakpointsInfo', numhl='DapUIBreakpointsInfo',
})
vim.fn.sign_define('DapStopped', {
  text='♛', texthl='DapUIStop', numhl='DapUIStop',
})
