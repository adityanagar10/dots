local M = {}

-- Competitive-programming judge submit pages, keyed by competitest's $(JUDGE)
-- value (lowercased directory name under ~/cp/<judge>/...).
local submit_urls = {
	codeforces = "https://codeforces.com/problemset/submit",
}

local runnable_filetypes = { cpp = true, go = true }

local function detect_judge()
	local path = vim.fn.expand("%:p")
	return path:match("/cp/([^/]+)/")
end

function M.enter_cp_mode()
	vim.cmd("ZenMode")

	if runnable_filetypes[vim.bo.filetype] then
		vim.cmd("CompetiTest run")
	else
		vim.notify(
			"competitest: not a runnable CP file (filetype '" .. vim.bo.filetype .. "'), skipping test runner",
			vim.log.levels.INFO
		)
	end
end

function M.copy_and_open_submit()
	vim.cmd("silent! %y+")

	local judge = detect_judge()
	local url = (judge and submit_urls[judge]) or submit_urls.codeforces

	vim.fn.jobstart({ "open", url }, { detach = true })
	print("Copied solution to clipboard, opened " .. url)
end

function M.setup()
	vim.keymap.set("n", "<leader>cp", M.enter_cp_mode, { desc = "Enter competitive programming mode" })
	vim.keymap.set("n", "<leader>cs", M.copy_and_open_submit, { desc = "Copy solution + open CF submit page" })
	vim.keymap.set("n", "<leader>ct", ":CompetiTest run<CR>", { desc = "Run testcases" })
	vim.keymap.set("n", "<leader>cr", ":CompetiTest receive persistently<CR>", { desc = "Receive testcases from Competitive Companion" })
end

return M
