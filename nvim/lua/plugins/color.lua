local poppy = {
	red = "#e06c75",
	green = "#98c379",
	yellow = "#e5c07b",
	orange = "#ff9e64",
	blue = "#61afef",
	cyan = "#56b6c2",
	purple = "#c678dd",
	magenta = "#c678dd",
	gray_blue = "#7dabd3",
	medium_gray_blue = "#8ec6e0",
	error = "#e06c75",
	warning = "#e5c07b",
	info = "#61afef",
	hint = "#56b6c2",
}

-- no-clown-fiesta's base palette is heavily desaturated (e.g. its "red" is
-- a muted brick, error/warning/info are nearly identical dull browns), and
-- a large share of syntax groups (Identifier, Constant, Operator, Type,
-- Delimiter...) just reuse the plain foreground color with no hue at all.
-- That reads as flat/low-contrast in real code and especially in log
-- output. This punches up saturation/distinction on the same roles rather
-- than swapping themes, so overall structure/layout stay put.
local function apply_overrides()
	for group, hl in pairs({
		String = { fg = poppy.green },
		Character = { fg = poppy.green },
		Number = { fg = poppy.orange },
		Boolean = { fg = poppy.orange },
		Float = { fg = poppy.orange },
		Function = { fg = poppy.blue },
		Macro = { fg = poppy.blue },
		Keyword = { fg = poppy.purple },
		Statement = { fg = poppy.purple },
		Conditional = { fg = poppy.purple },
		Repeat = { fg = poppy.purple },
		Exception = { fg = poppy.red },
		Include = { fg = poppy.red },
		Define = { fg = poppy.red },
		Type = { fg = poppy.cyan },
		StorageClass = { fg = poppy.cyan },
		Structure = { fg = poppy.cyan },
		SpecialChar = { fg = poppy.medium_gray_blue },
		Tag = { fg = poppy.blue },
		Todo = { fg = poppy.red, bold = true },

		-- treesitter groups (what actually drives modern LSP/TS highlighting)
		["@string"] = { fg = poppy.green },
		["@string.special"] = { fg = poppy.medium_gray_blue },
		["@number"] = { fg = poppy.orange },
		["@boolean"] = { fg = poppy.orange },
		["@function"] = { fg = poppy.blue },
		["@function.call"] = { fg = poppy.blue },
		["@function.method"] = { fg = poppy.blue },
		["@function.method.call"] = { fg = poppy.blue },
		["@constructor"] = { fg = poppy.cyan },
		["@keyword"] = { fg = poppy.purple },
		["@keyword.function"] = { fg = poppy.purple },
		["@keyword.return"] = { fg = poppy.purple },
		["@keyword.operator"] = { fg = poppy.purple },
		["@conditional"] = { fg = poppy.purple },
		["@repeat"] = { fg = poppy.purple },
		["@type"] = { fg = poppy.cyan },
		["@type.builtin"] = { fg = poppy.cyan },
		["@variable.parameter"] = { fg = poppy.gray_blue },
		["@property"] = { fg = poppy.gray_blue },
		["@tag"] = { fg = poppy.blue },
		["@tag.attribute"] = { fg = poppy.cyan },
		["@punctuation.bracket"] = { fg = poppy.medium_gray_blue },
		["@punctuation.delimiter"] = { fg = poppy.medium_gray_blue },

		-- diagnostics (this is what made log-level lines like INFO/WARN in
		-- :terminal / quickfix / LSP output blend together)
		DiagnosticError = { fg = poppy.error },
		DiagnosticWarn = { fg = poppy.warning },
		DiagnosticInfo = { fg = poppy.info },
		DiagnosticHint = { fg = poppy.hint },
		DiagnosticFloatingError = { fg = poppy.error },
		ErrorMsg = { fg = poppy.error, bold = true },
		WarningMsg = { fg = poppy.warning },

		-- git signs
		GitSignsAdd = { fg = poppy.green },
		GitSignsChange = { fg = poppy.blue },
		GitSignsDelete = { fg = poppy.red },
	}) do
		vim.api.nvim_set_hl(0, group, hl)
	end
end

return {
	"aktersnurra/no-clown-fiesta.nvim",
	priority = 1000,
	config = function()
		require("no-clown-fiesta").setup({
			transparent = true,
		})
		vim.cmd.colorscheme("no-clown-fiesta")
		apply_overrides()

		-- re-apply on any colorscheme (re)load, e.g. `:colorscheme no-clown-fiesta`
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "no-clown-fiesta",
			callback = function()
				vim.schedule(apply_overrides)
			end,
		})
	end,
}
