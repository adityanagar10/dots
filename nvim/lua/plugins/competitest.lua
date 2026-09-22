return {
	"xeluxee/competitest.nvim",
	dependencies = "MunifTanjim/nui.nvim",
	config = function()
		require("competitest").setup({
			-- $(PROBLEM)/$(CONTEST)/$(JUDGE) are raw human-readable names from
			-- Competitive Companion (e.g. "A. Domino piling", "Codeforces Beta
			-- Round 47") and can contain spaces/periods that break file paths.
			-- $(JAVA_TASK_CLASS) is competitest's own sanitized, classname-safe
			-- version of the problem name — use that for filenames instead, and
			-- flatten everything into one directory to avoid the unsanitized
			-- contest name entirely.
			received_problems_path = "$(HOME)/cp/codeforces/$(JAVA_TASK_CLASS).$(FEXT)",
			received_contests_directory = "$(HOME)/cp/codeforces",
			received_contests_problems_path = "$(JAVA_TASK_CLASS).$(FEXT)",

			-- template_file (table form) is looked up with a raw "^~" gsub only —
			-- $(HOME) is never expanded here (unlike received_problems_path,
			-- which goes through full modifier evaluation), so "$(HOME)/..."
			-- silently resolves to a nonexistent path and the template gets
			-- skipped with no file ever populated. Must use ~ here specifically.
			template_file = {
				cpp = "~/cp/templates/template.cpp",
				go = "~/cp/templates/template.go",
			},
			evaluate_template_modifiers = true,

			compile_command = {
				cpp = { exec = "g++", args = { "-O2", "-std=c++20", "$(FNAME)", "-o", "$(FNOEXT)" } },
				go = { exec = "go", args = { "build", "-o", "$(FNOEXT)", "$(FNAME)" } },
			},
			run_command = {
				cpp = { exec = "./$(FNOEXT)" },
				go = { exec = "./$(FNOEXT)" },
			},

			testcases_use_single_file = false,
			runner_ui = {
				interface = "split",
				selector_show_nu = true,
				show_nu = true,
				show_rnu = false,
			},
		})
	end,
}
