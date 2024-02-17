local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

mason_lspconfig.setup({
  ensure_installed = {
    "tsserver",
    "emmet_ls",
    "html",
    "cssls",
    "tailwindcss",
    "astro",
    "lua_ls",
    "pylsp",
    "clangd",
    "bashls",
    "texlab",
    "marksman",
    "ast_grep",
    "clangd",
    "rust_analyzer",
  }
})

-- formaters:
-- easy-coding-standard
-- ast-grep ast_grep
-- beautysh
-- clang-format
-- djlint
-- latexindent
-- mdformat
-- prettier
-- pretty-php
-- standardjs

-- linters:
-- easy-coding-standard
-- ast-grep ast_grep
-- djlint
-- standardjs
-- stylelint
