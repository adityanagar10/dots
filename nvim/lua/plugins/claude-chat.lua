return {
  "wtfox/claude-chat.nvim",
  config = true,
  opts = {
    -- Optional configuration
    split = "vsplit",      -- "vsplit" or "split"
    position = "right",    -- "right", "left", "top", "bottom"
    width = 0.4,           -- percentage of screen width (for vsplit)
    height = 0.4,          -- percentage of screen height (for split)
    claude_cmd = "claude", -- command to invoke Claude Code
  },
  keys = {
    { "<leader>cc", ":ClaudeChat<CR>", desc = "Ask Claude", mode = { "n", "v" } },
  },
}
