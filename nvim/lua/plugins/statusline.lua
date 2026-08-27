return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "echasnovski/mini.icons" },
  config = function()
    -- Ensure statusline is always visible
    vim.opt.laststatus = 3  -- Global statusline (or use 2 for per-window)

    require("lualine").setup({
      options = {
        icons_enabled = false,
        theme = "auto",
        component_separators = "",
        section_separators = "",
      },

      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { "filename" },
        lualine_x = {
          function()
            local encoding = vim.o.fileencoding
            if encoding == "" then
              return vim.bo.fileformat .. " :: " .. vim.bo.filetype
            else
              return encoding .. " :: " .. vim.bo.fileformat .. " :: " .. vim.bo.filetype
            end
          end,
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
