-- use tab interchangably for indenting text and accepting copilot suggestions
-- vim.keymap.set('i', '<Tab>', function()
--   if require("copilot.suggestion").is_visible() then
--     require("copilot.suggestion").accept()
--   else
--     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
--   end
-- end, { desc = "Super Tab" })

-- nvim-cmp setup
local function cmp_setup()
  require("luasnip.loaders.from_snipmate").load()

  local cmp = require('cmp')
  local luasnip = require('luasnip')

  local mapping = {
    ['<CR>'] = function(fallback)
      if cmp.get_selected_entry() then
        cmp.confirm()
        return
      end

      fallback()
    end,
    ['<C-SPACE>'] = cmp.mapping.complete(),
    ["<C-n>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
        return
      end

      fallback()
    end, { "i", "s", "c" }),
    ["<C-p>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
        return
      end

      fallback()
    end, { "i", "s", "c" }),
    ['<C-k>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
        return
      end

      fallback()
    end, { "i", "s" }),
  }

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = mapping,
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'path' },
      { name = 'nvim_lua' },
      { name = 'luasnip' },
    },
    window = {
      documentation = cmp.config.window.bordered(),
      completion = cmp.config.window.bordered(),
    },
  })

  -- command line completion
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = mapping,
    sources = {
      { name = 'path' },
      { name = 'buffer' },
    },
  })

  cmp.setup.cmdline(':', {
    mapping = mapping,
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
  })
end

-- require("luasnip.loaders.from_snipmate").lazy_load()

return {
  { 'github/copilot.vim' },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },                       -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken",                          -- Only on MacOS or Linux
    opts = {
      -- model = "gpt-4o",
      -- model = "gemini-2.0-flash-001",
      model = "claude-3.7-sonnet",
      contexts = {
        jeeves = {
          resolve = function()
            return require('jeeves').collect_context()
          end,
        },
      },
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)
      local model = require("CopilotChat").config.model
      local chat = function()
        vim.ui.input({ prompt = model .. ": " }, function(input)
          if input then
            vim.cmd("CopilotChat " .. input)
          end
        end)
      end

      vim.keymap.set("n", "<leader>i", chat, { desc = "Ask Copilot" })
      vim.keymap.set("v", "<leader>i", chat, { desc = "Ask Copilot" })
      vim.keymap.set("n", "<leader>c", "<cmd>CopilotChat<CR>", { desc = "Copilot Chat" })
      vim.keymap.set("v", "<leader>c", "<cmd>CopilotChat<CR>", { desc = "Copilot Chat" })
    end,
  },
  {
    'angles-n-daemons/jeeves',
    keys = {
      {
        mode = { 'v' },
        'M', -- hit M in visual mode to add the selection to your context.
        function()
          require('jeeves').add_selection()
        end,
      },
      {
        mode = { 'n' },
        'M', -- hit M in normal mode to remove the selection under your cursor.
        function()
          require('jeeves').remove_selections_under_cursor()
        end,
      },
      {
        '<leader>jc',
        function()
          require('jeeves').clear()
        end,
      },
    },
  },
  { 'L3MON4D3/LuaSnip' },
  { 'hrsh7th/nvim-cmp',    config = cmp_setup },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-nvim-lua' },
}
