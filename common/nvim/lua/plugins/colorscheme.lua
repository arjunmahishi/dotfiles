return {
  {
    "folke/tokyonight.nvim",
    opts = function()
      on_colors = function(colors)
        colors.gitSigns = {
          add = colors.green,
          change = colors.orange,
          delete = colors.red,
          conflict = '#e5c07b',
        }
      end
    end
  },
  { "tjdevries/colorbuddy.nvim" },
  { "luisiacc/gruvbox-baby" },
}
