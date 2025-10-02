-- Bootstrap lazy.nvim and LazyVim
require("config.lazy")

-- Load utils module
local utils = require("utils")

-- Setup color overrides
utils.color_overrides.setup_colorscheme_overrides()
