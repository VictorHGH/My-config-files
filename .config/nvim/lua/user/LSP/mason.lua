local mason = require("mason")
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
    "clangd",
    "rust_analyzer",
    "easy-coding-standard",
    "ast_grep",
    "beautysh",
    "clang-format",
    "djlint",
    "latexindent",
    "mdformat",
    "pretty-php",
    "stylelint",
    "json-lsp",
    "jsonlint",
    "oxlint",
    "biome",
  },
  auto_update = true,
  run_on_start = true,
})
