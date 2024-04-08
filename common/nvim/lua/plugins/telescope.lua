return {
  'nvim-telescope/telescope.nvim', tag = '0.1.5',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-live-grep-args.nvim',
      config = function()
        require('telescope').load_extension('live_grep_args')
      end,
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      config = function()
        require('telescope').load_extension('fzf')
      end,
    },
  },
  config = function()
    local actions = require('telescope.actions')

    require('telescope').setup({
      defaults = {
        file_ignore_patterns = {'node_modules', 'coverage'},
        mapping = { i = { ["<esc>"] = actions.close } }
      },

      pickers = {
        find_files = {
          file_ignore_patterns = {'vendor/'}
        }
      },

      extensions = {
        live_grep_args = {
          theme = "ivy",
        }
      },
    })

    -- keymaps
    local map = vim.api.nvim_set_keymap
    local noremap = { noremap = true }

    map('n', '<C-p>', '<cmd>lua TelescopeIntoDir(".")<CR>', {})
    map('n', '<leader>w', '<cmd>lua TelescopeIntoDir("~/work")<CR>', {})
    map('n', '<C-f>', "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", noremap)
    map('n', '<leader>tc', '<cmd>Telescope commands theme=ivy<CR>', noremap)
    map('n', '<leader>th', '<cmd>Telescope help_tags theme=ivy<CR>', noremap)
    map('n', '<leader>tb', '<cmd>Telescope buffers theme=ivy<CR>', noremap)
    map('n', '<leader>t=', '<cmd>Telescope spell_suggest theme=ivy<CR>', noremap)
    map('n', '<leader>t/', '<cmd>Telescope current_buffer_fuzzy_find theme=ivy<CR>', noremap)
    map('n', '<leader>tw', '<cmd>lua require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({postfix = \' -t all\'})<CR>', noremap)
    map('v', '<leader>tw', '<cmd>lua require("telescope-live-grep-args.shortcuts").grep_visual_selection({postfix = \' -t all\'})<CR>', noremap)
    map('n', '<leader>tgb', '<cmd>Telescope git_branches theme=ivy<CR>', noremap)
    map('n', '<leader>tgs', '<cmd>Telescope git_status theme=ivy<CR>', noremap)
  end,
}
