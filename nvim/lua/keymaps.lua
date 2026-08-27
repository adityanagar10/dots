local km = vim.keymap.set

-- remaps
vim.g.mapleader = " "
vim.g.maplocalleader = ","

km("n", "<C-h>", "<C-w>h")
km("n", "<C-j>", "<C-w>j")
km("n", "<C-k>", "<C-w>k")
km("n", "<C-l>", "<C-w>l")

-- terminal mode navigation
km("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window from terminal" })
km("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Go to bottom window from terminal" })
km("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Go to top window from terminal" })
km("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window from terminal" })

-- alternative: Alt key navigation from terminal (in case Ctrl conflicts)
km("t", "<M-h>", "<C-\\><C-n><C-w>h", { desc = "Go to left window from terminal" })
km("t", "<M-j>", "<C-\\><C-n><C-w>j", { desc = "Go to bottom window from terminal" })
km("t", "<M-k>", "<C-\\><C-n><C-w>k", { desc = "Go to top window from terminal" })
km("t", "<M-l>", "<C-\\><C-n><C-w>l", { desc = "Go to right window from terminal" })

-- alternative window navigation (in case tmux plugin interferes)
km("n", "<leader>H", "<C-w>h", { desc = "Go to left split" })
km("n", "<leader>J", "<C-w>j", { desc = "Go to bottom split" })
km("n", "<leader>K", "<C-w>k", { desc = "Go to top split" })
km("n", "<leader>L", "<C-w>l", { desc = "Go to right split" })

-- because [e goes to the next error
-- for consistency
km("n", "[s", "]s")
km("n", "]s", "[s")

-- window manips
-- create splits
km("n", "<leader>wv", ":vsplit<CR>", { silent = true, desc = "Split window vertically" })
km("n", "<leader>wh", ":split<CR>", { silent = true, desc = "Split window horizontally" })
km("n", "<leader>wc", ":close<CR>", { silent = true, desc = "Close current window" })
km("n", "<leader>wo", ":only<CR>", { silent = true, desc = "Close all other windows" })

-- resize splits (using arrow-like keys)
km("n", "=", [[<cmd>vertical resize +5<cr>]])
km("n", "-", [[<cmd>vertical resize -5<cr>]])
km("n", "+", [[<cmd>horizontal resize +5<cr>]])
km("n", "^", [[<cmd>horizontal resize +5<cr>]])

-- easier window resizing with leader + rhjkl (r for resize)
km("n", "<leader>rk", ":resize +2<CR>", { silent = true, desc = "Increase height" })
km("n", "<leader>rj", ":resize -2<CR>", { silent = true, desc = "Decrease height" })
km("n", "<leader>rh", ":vertical resize -2<CR>", { silent = true, desc = "Decrease width" })
km("n", "<leader>rl", ":vertical resize +2<CR>", { silent = true, desc = "Increase width" })

-- alternative: leader-based resizing for easier access
km("n", "<leader>w=", "<C-w>=", { desc = "Make splits equal size" })
km("n", "<leader>w|", "<C-w>|", { desc = "Maximize width" })
km("n", "<leader>w_", "<C-w>_", { desc = "Maximize height" })

-- move selections
km("v", "J", ":m '>+1<CR>gv=gv") -- Shift visual selected line down
km("v", "K", ":m '<-2<CR>gv=gv") -- Shift visual selected line up
km("n", "<leader>t", "bv~")

-- colorscheme picker
km("n", "<C-n>", ":Telescope colorscheme<CR>")

-- clear search highlights
km("n", "<Esc>", ":nohlsearch<CR>", { silent = true })


km("n", "<C-d>", "<C-d>zz")
km("n", "<C-u>", "<C-u>zz")
km("n", "<C-f>", "<C-f>zz")
km("n", "<C-b>", "<C-b>zz")
km("n", "Y", "yy")

-- autocomplete in normal text
km("i", "<C-f>", "<C-x><C-f>", { noremap = true, silent = true })
km("i", "<C-n>", "<C-x><C-n>", { noremap = true, silent = true })
km("i", "<C-l>", "<C-x><C-l>", { noremap = true, silent = true })

-- spell check
km("n", "<leader>ll", ":setlocal spell spelllang=en_us<CR>")

-- lsp setup
km("n", "K", vim.lsp.buf.hover)
km("n", "gd", function()
  vim.lsp.buf.definition()

  vim.defer_fn(function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "qf",
      callback = function()
        vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "<CR>:cclose<CR>:lclose<CR>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, "n", "q", ":cclose<CR>:lclose<CR>", { noremap = true, silent = true })
      end,
    })
  end, 0)
end)
km("n", "gD", vim.lsp.buf.declaration)
km("n", "gr", function()
  -- Trigger the LSP references function and populate the quickfix list
  vim.lsp.buf.references()

  vim.defer_fn(function()
    -- Set up an autocmd to remap keys in the quickfix window
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "qf", -- Only apply this mapping in quickfix windows
      callback = function()
        -- Remap <Enter> to jump to the location and close the quickfix window
        vim.api.nvim_buf_set_keymap(0, "n", "<CR>", "<CR>:cclose<CR>", { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(0, "n", "q", ":cclose<CR>", { noremap = true, silent = true })

        -- Set up <Tab> to cycle through quickfix list entries
        km("n", "<Tab>", function()
          local current_idx = vim.fn.getqflist({ idx = 0 }).idx
          local qflist = vim.fn.getqflist() -- Get the current quickfix list
          if current_idx >= #qflist then
            vim.cmd("cfirst")
            vim.cmd("wincmd p")
          else
            vim.cmd("cnext")
            vim.cmd("wincmd p")
          end
        end, { noremap = true, silent = true, buffer = 0 })

        km("n", "<S-Tab>", function()
          local current_idx = vim.fn.getqflist({ idx = 0 }).idx
          if current_idx < 2 then
            vim.cmd("clast")
            vim.cmd("wincmd p")
          else
            vim.cmd("cprev")
            vim.cmd("wincmd p")
          end
        end, { noremap = true, silent = true, buffer = 0 })
      end,
    })
  end, 0)
end)

km({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})

-- see error
km("n", "<leader>e", vim.diagnostic.open_float)

-- go to errors
km("n", "[e", vim.diagnostic.goto_next)
km("n", "]e", vim.diagnostic.goto_next)

-- buffer navigation
km("n", "<Tab>", ":bnext<CR>", { silent = true })
km("n", "<S-Tab>", ":bprevious<CR>", { silent = true })
km("n", "<leader>bd", ":bdelete<CR>", { silent = true })
km("n", "<leader>bD", ":bdelete!<CR>", { silent = true })
km("n", "<leader>bo", ":%bdelete|edit #|normal `\"<CR>", { silent = true }) -- close all but current buffer

-- Copy file paths
km("n", "<leader>fp", function()
  local path = vim.fn.expand("%:.")
  vim.fn.system("pbcopy", path)
  vim.notify('Copied relative path: ' .. path, vim.log.levels.INFO)
end, { silent = true, desc = "Copy relative file path" })

km("n", "<leader>fP", function()
  local path = vim.fn.expand("%:p")
  vim.fn.system("pbcopy", path)
  vim.notify('Copied absolute path: ' .. path, vim.log.levels.INFO)
end, { silent = true, desc = "Copy absolute file path" })

-- Claude Code sharing
km("v", "<leader>c", ":w! /tmp/claude-share.txt<CR>", { silent = true, desc = "Share selection with Claude Code" })
km("n", "<leader>c", ":.w! /tmp/claude-share.txt<CR>", { silent = true, desc = "Share current line with Claude Code" })
