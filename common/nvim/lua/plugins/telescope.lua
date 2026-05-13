return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.5',
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
        require('telescope').load_extension('flow')
      end,
    },
  },
  config = function()
    local actions = require('telescope.actions')

    require('telescope').setup({
      defaults = {
        file_ignore_patterns = { 'node_modules', 'coverage', 'vendor' },
        mapping = { i = { ["<esc>"] = actions.close } },
        theme = "ivy",
        path_display = { shorten = { len = 1, exclude = { -1, -2 } } },
      },

      pickers = {
        find_files = {
          file_ignore_patterns = { 'vendor/' }
        }
      },

      extensions = {
        live_grep_args = {
          theme = "ivy",
        }
      },
    })

    -- keymaps
    vim.keymap.set('n', '<C-p>', function() TelescopeIntoDir(".") end)
    vim.keymap.set('n', '<C-f>', "<cmd>Telescope live_grep_args theme=ivy<CR>")
    vim.keymap.set('n', '<leader>tc', '<cmd>Telescope commands theme=ivy<CR>')
    vim.keymap.set('n', '<leader>th', '<cmd>Telescope help_tags theme=ivy<CR>')
    vim.keymap.set('n', '<leader>tb', '<cmd>Telescope buffers theme=ivy<CR>')
    vim.keymap.set('n', '<leader>t=', '<cmd>Telescope spell_suggest theme=ivy<CR>')
    vim.keymap.set('n', '<leader>t/', '<cmd>Telescope current_buffer_fuzzy_find theme=ivy<CR>')
    vim.keymap.set('n', '<leader>tw', function()
      require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({ postfix = ' -t all', theme = "ivy" })
    end)
    vim.keymap.set('v', '<leader>tw', function()
      require("telescope-live-grep-args.shortcuts").grep_visual_selection({ postfix = ' -t all', theme = "ivy" })
    end)
    vim.keymap.set('n', '<leader>tgb', '<cmd>Telescope git_branches theme=ivy<CR>')
    vim.keymap.set('n', '<leader>tgs', '<cmd>Telescope git_status theme=ivy<CR>')
    vim.keymap.set('n', '<leader>ts', '<cmd>Telescope lsp_document_symbols theme=ivy<CR>')
    vim.keymap.set('n', 'gR', '<cmd>Telescope lsp_references theme=ivy<CR>')
  end,
}
