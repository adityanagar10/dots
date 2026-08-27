return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require('gitsigns').setup({
      signcolumn = false,  -- You have signcolumn disabled
      numhl = true,        -- Highlight line numbers instead
      linehl = false,
      word_diff = false,
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 500,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',

      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local km = vim.keymap.set

        -- Navigation
        km('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true, buffer = bufnr, desc = "Next git change"})

        km('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true, buffer = bufnr, desc = "Previous git change"})

        -- Actions
        km('n', '<leader>hs', gs.stage_hunk, {buffer = bufnr, desc = "Stage hunk"})
        km('n', '<leader>hr', gs.reset_hunk, {buffer = bufnr, desc = "Reset hunk"})
        km('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {buffer = bufnr, desc = "Stage selected lines"})
        km('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end, {buffer = bufnr, desc = "Reset selected lines"})
        km('n', '<leader>hS', gs.stage_buffer, {buffer = bufnr, desc = "Stage buffer"})
        km('n', '<leader>hu', gs.undo_stage_hunk, {buffer = bufnr, desc = "Undo stage hunk"})
        km('n', '<leader>hR', gs.reset_buffer, {buffer = bufnr, desc = "Reset buffer"})
        km('n', '<leader>hp', gs.preview_hunk, {buffer = bufnr, desc = "Preview hunk"})
        km('n', '<leader>hb', function() gs.blame_line{full=true} end, {buffer = bufnr, desc = "Blame line"})
        km('n', '<leader>hB', gs.toggle_current_line_blame, {buffer = bufnr, desc = "Toggle line blame"})
        km('n', '<leader>hd', gs.diffthis, {buffer = bufnr, desc = "Diff this"})
        km('n', '<leader>hD', function() gs.diffthis('~') end, {buffer = bufnr, desc = "Diff against last commit"})

        -- Text object
        km({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {buffer = bufnr, desc = "Select hunk"})
      end
    })
  end
}
