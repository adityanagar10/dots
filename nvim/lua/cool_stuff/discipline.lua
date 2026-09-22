-- Nags if you spam raw hjkl/+/- motions instead of using counts or better
-- navigation (search, telescope, etc). Adapted from craftzdog/dotfiles.
local M = {}

function M.setup()
	for _, key in ipairs({ "h", "j", "k", "l", "+", "-" }) do
		local count = 0
		local timer = assert(vim.uv.new_timer())
		vim.keymap.set("n", key, function()
			if vim.v.count > 0 then
				count = 0
			end
			if count >= 10 and vim.bo.buftype ~= "nofile" then
				-- notify, then swallow this keypress (expr-mapping returns
				-- nil) so spamming raw hjkl actually stops working for a
				-- moment instead of just nagging while still moving
				local ok = pcall(vim.notify, "Hold it Cowboy!", vim.log.levels.WARN, {
					icon = "🤠",
					id = "cowboy",
					keep = function()
						return count >= 10
					end,
				})
				if not ok then
					return key
				end
			else
				count = count + 1
				timer:start(2000, 0, function()
					count = 0
				end)
				return key
			end
		end, { expr = true, silent = true })
	end
end

return M
