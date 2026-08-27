return {
	"xeluxee/competitest.nvim",
	dependencies = "MunifTanjim/nui.nvim",
	config = function()
		require("competitest").setup({
			received_problems_path = "$(HOME)/cp/$(JUDGE)/$(CONTEST)/$(PROBLEM).$(FEXT)",
			received_contests_directory = "$(HOME)/cp/$(JUDGE)/$(CONTEST)",
			received_contests_problems_path = "$(PROBLEM).$(FEXT)",

			template_file = {
				cpp = "$(HOME)/cp/templates/template.cpp",
				go = "$(HOME)/cp/templates/template.go",
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
