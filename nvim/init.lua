local utils = require("utils")

require("options")
require("keymaps")
require("custom_filetypes")
require("lazynvim")
require("cool_stuff")
require("mappings")

utils.fix_telescope_parens_win()
utils.dashboard.setup_dashboard_image_colors()
