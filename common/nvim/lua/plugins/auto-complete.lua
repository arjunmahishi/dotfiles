-- use tab interchangably for indenting text and accepting copilot suggestions
vim.keymap.set('i', '<Tab>', function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end, { desc = "Super Tab" })

-- nvim-cmp setup
local function cmp_setup()
  local cmp = require('cmp')

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
  }

  cmp.setup({
    snippet = {},
    mapping = mapping,
    sources = {
      { name = 'nvim_lsp' },
      { name = 'buffer' },
      { name = 'path' },
      { name = 'vsnip' },
      { name = 'nvim_lua' },
    },
    window = {
      documentation = cmp.config.window.bordered(),
      completion = cmp.config.window.bordered(),
    },
  })

  -- command line completion
  cmp.setup.cmdline({'/', '?'}, {
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


return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = { ["*"] = true },
      suggestion = {
        enabled = true,
        auto_trigger = false,
        debounce = 75,
        keymap = {
          accept = "<Tab>", next = "<S-Tab>",
        },
      },
    },
  },
  { 'hrsh7th/nvim-cmp', config = cmp_setup },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-path' },
  { 'hrsh7th/cmp-cmdline' },
  { 'hrsh7th/cmp-nvim-lua' },
}
