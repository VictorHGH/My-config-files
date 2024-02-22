local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")

mason.setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

mason_tool_installer.setup({
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
    "easy-coding-standard",
    "ast_grep",
    "beautysh",
    "clang-format",
    "djlint",
    "latexindent",
    "mdformat",
    "prettier",
    "pretty-php",
    "standardjs",
    "stylelint",
  },
  auto_update = true,
  run_on_start = true,
  start_delay = 2000
})
