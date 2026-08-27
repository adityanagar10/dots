return {
	"xiyaowong/transparent.nvim",
	config = function()
		require("transparent").setup({
			enable = true,
			extra_groups = {
				"NormalFloat",
				"NvimTreeNormal",
			},
			exclude_groups = {}, -- Don't exclude any groups
		})

		-- Ensure transparency is maintained on colorscheme changes
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = function()
				vim.cmd("TransparentEnable")
			end,
		})
	end,
}
