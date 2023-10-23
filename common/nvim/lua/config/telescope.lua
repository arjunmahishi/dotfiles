local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    file_ignore_patterns = {'node_modules', 'coverage'},
    mapping = { i = { ["<esc>"] = actions.close } }
  }
}

require('telescope').load_extension('fzf')
-- require('telescope').load_extension('git_worktree')
require('telescope').load_extension('gh')
-- require('telescope').load_extension('luasnip')

local map = vim.api.nvim_set_keymap
local noremap = { noremap = true }

map('n', '<C-p>', '<cmd>lua TelescopeIntoDir(".")<CR>', {})
map('n', '<leader>w', '<cmd>lua TelescopeIntoDir("~/work")<CR>', {})
map('n', '<C-f>', '<cmd>Telescope live_grep theme=ivy<CR>', {})
map('n', '<leader>tw', '<cmd>Telescope grep_string theme=ivy<CR>', noremap)
map('n', '<leader>tc', '<cmd>Telescope commands theme=ivy<CR>', noremap)
map('n', '<leader>th', '<cmd>Telescope help_tags theme=ivy<CR>', noremap)
map('n', '<leader>tb', '<cmd>Telescope buffers theme=ivy<CR>', noremap)
map('n', '<leader>t=', '<cmd>Telescope spell_suggest theme=ivy<CR>', noremap)
-- map('n', '<C-O>', '<cmd>Telescope luasnip theme=ivy<CR>', noremap)
