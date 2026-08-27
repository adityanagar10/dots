return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        PATH = "prepend",
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "fortls",
          -- "nil_ls",
          "bashls",
          "omnisharp",
          "cmake",
          "lua_ls",
          "gopls",
          "templ",
          "html",
          "cssls",
          "emmet_ls",
          "tailwindcss",
          "ts_ls",
          "astro",
          "ols",
          -- "gdscript",
          -- "tsserver",
          "pylsp",
          "clangd",
          "prismals",
          "yamlls",
          "jsonls",
          "eslint",
          -- "hls",
          -- "zls",
          "marksman",
          "sqlls",
          "wgsl_analyzer",
          "texlab",
          "intelephense",
          "nim_langserver",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- helper: root_dir function equivalent to the old root_pattern(...) usage
      local function root_pattern(...)
        local patterns = { ... }
        return function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(require("lspconfig.util").root_pattern(unpack(patterns))(fname))
        end
      end

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("cmake", {})
      vim.lsp.config("fortls", {
        root_dir = root_pattern("*.f90"),
      })
      vim.lsp.config("purescriptls", {
        filetypes = { "purescript" },
        settings = {
          purescript = {
            addSpagoSources = true, -- e.g. any purescript language-server config here
          },
        },
        flags = {
          debounce_text_changes = 150,
        },
      })
      vim.lsp.config("ols", {
        root_dir = root_pattern("*.odin"),
      })
      vim.lsp.config("ocamllsp", {
        cmd = { "ocamllsp", "--stdio" },
        filetypes = { "ocaml", "reason" },
        root_dir = root_pattern("*.opam", "esy.json", "package.json"),
      })

      if not vim.lsp.config.roc_ls then
        vim.lsp.config("roc_ls", {
          cmd = { "roc_language_server", "--stdio" },
          filetypes = { "roc" },
        })
      end

      -- vim.lsp.config("gdscript", {
      --   filetypes = { "gd", "gdscript", "gdscript3" },
      -- })
      vim.lsp.config("astro", {})
      vim.lsp.config("nil_ls", {})
      vim.lsp.config("sqlls", {})
      vim.lsp.config("intelephense", {})
      vim.lsp.config("texlab", {})
      vim.lsp.config("zls", {
        cmd = { "zls" },
      })
      vim.lsp.config("hls", {})
      vim.lsp.config("bashls", {})
      vim.lsp.config("lua_ls", {
        -- cmd = { "lua_ls" },
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- Recognize 'vim' as a global variable
            },
            workspace = {
              library = {
                vim.api.nvim_get_runtime_file("", true),
                "${3rd}/love2d/library"
              }, -- Include Neovim runtime files
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
      vim.lsp.config("wgsl_analyzer", {})
      vim.lsp.config("jsonls", {})
      vim.lsp.config("gopls", {})
      vim.lsp.config("cssls", {})
      vim.lsp.config("prismals", {})
      vim.lsp.config("yamlls", {})
      -- vim.lsp.config("html", {
      --   filetypes = {
      --     "templ",
      --     "html",
      --     "php",
      --     "css",
      --     "javascriptreact",
      --     "typescriptreact",
      --     "javascript",
      --     "typescript",
      --     "jsx",
      --     "tsx",
      --   },
      -- })
      -- vim.lsp.config("htmx", {
      --   filetypes = { "html", "templ" },
      -- })
      vim.lsp.config("emmet_ls", {
        filetypes = {
          "templ",
          "html",
          "css",
          "php",
          "javascript",
          "javascriptreact",
          "typescriptreact",
          "typescript",
          "jsx",
          "tsx",
        },
      })
      -- vim.lsp.config("tailwindcss", {
      -- 	filetypes = {
      -- 		"templ",
      -- 		"html",
      -- 		"css",
      -- 		"javascriptreact",
      -- 		"typescriptreact",
      -- 		"javascript",
      -- 		"typescript",
      -- 		"jsx",
      -- 		"tsx",
      -- 	},
      -- 	root_dir = root_pattern(
      -- 		"tailwind.config.js",
      -- 		"tailwind.config.cjs",
      -- 		"tailwind.config.mjs",
      -- 		"tailwind.config.ts",
      -- 		"postcss.config.js",
      -- 		"postcss.config.cjs",
      -- 		"postcss.config.mjs",
      -- 		"postcss.config.ts",
      -- 		"package.json",
      -- 		"node_modules",
      -- 		".git"
      -- 	),
      -- })
      vim.lsp.config("templ", {
        filetypes = { "templ" },
      })

      if not vim.lsp.config.ts_ls then
        vim.lsp.config("ts_ls", {
          cmd = { "typescript-language-server", "--stdio" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "html",
          },
          root_dir = root_pattern("package.json", "tsconfig.json", ".git"),
        })
      end
      vim.lsp.config("eslint", {})

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--pch-storage=memory",
          "--all-scopes-completion",
          "--pretty",
          "--header-insertion=never",
          "-j=4",
          "--inlay-hints",
          "--header-insertion-decorators",
          "--function-arg-placeholders",
          "--completion-style=detailed",
        },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_dir = root_pattern("src"),
        init_option = { fallbackFlags = { "-std=c++2a" } },
      })

      function get_python_path()
        -- Check if there's an active virtual environment
        local venv_path = os.getenv("VIRTUAL_ENV")
        if venv_path then
          return venv_path .. "/bin/python3"
        else
          -- get os name
          local os_name = require("utils").get_os()
          -- get os interpreter path
          if os_name == "windows" then
            return "C:/python312"
          elseif os_name == "linux" then
            return "/usr/bin/python3"
          else
            return "/Library/Frameworks/Python.framework/Versions/3.11/bin/python3"
          end
          -- Fallback to global Python interpreter
        end
      end

      vim.lsp.config("pylsp", {
        settings = {
          python = {
            pythonPath = get_python_path(),
          },
        },
      })

      vim.lsp.config("marksman", {})
      vim.lsp.config("gleam", {})
      vim.lsp.config("nim_langserver", {})
      vim.lsp.config("omnisharp", {
        cmd = { "OmniSharp" },
      })
      vim.lsp.config("fennel_ls", {
        cmd = { "fennel-ls" },
      })
      vim.lsp.config("rescriptls", {
        cmd = { "rescript-language-server", "--stdio" },
        root_dir = root_pattern("rescript.json"),
      })
      vim.lsp.config("julials", {
        cmd = { "julia-lsp" },
        root_dir = root_pattern("*.jl"),
      })

      vim.lsp.enable({
        "cmake",
        "fortls",
        "purescriptls",
        "ols",
        "ocamllsp",
        "roc_ls",
        "astro",
        "nil_ls",
        "sqlls",
        "intelephense",
        "texlab",
        "zls",
        "hls",
        "bashls",
        "lua_ls",
        "wgsl_analyzer",
        "jsonls",
        "gopls",
        "cssls",
        "prismals",
        "yamlls",
        "emmet_ls",
        "templ",
        "ts_ls",
        "eslint",
        "clangd",
        "pylsp",
        "marksman",
        "gleam",
        "nim_langserver",
        "omnisharp",
        "fennel_ls",
        "rescriptls",
        "julials",
      })
    end,
  },
}
