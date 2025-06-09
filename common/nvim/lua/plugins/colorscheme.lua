return {
	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	opts = function()
	-- 		on_colors = function(colors)
	-- 			colors.gitSigns = {
	-- 				add = colors.green,
	-- 				change = colors.orange,
	-- 				delete = colors.red,
	-- 				conflict = "#e5c07b",
	-- 			}
	-- 		end
	-- 	end,
	-- },
	{ "tjdevries/colorbuddy.nvim" },
	{
		"sainnhe/gruvbox-material",
		enabled = true,
		priority = 1000,
		config = function()
			vim.g.gruvbox_material_transparent_background = 1
			vim.g.gruvbox_material_foreground = "mix"
			vim.g.gruvbox_material_background = "hard"
			vim.g.gruvbox_material_ui_contrast = "high"
			vim.g.gruvbox_material_float_style = "bright"
			vim.g.gruvbox_material_statusline_style = "material"
			vim.g.gruvbox_material_cursor = "auto"
			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
}
