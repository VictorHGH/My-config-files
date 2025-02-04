local mason = require("mason")
local mason_tool_installer = require("mason-tool-installer")

mason.setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "...",
			package_uninstalled = "X",
		},
	},
})

mason_tool_installer.setup({
	ensure_installed = {
		"astro-language-server",
		"bash-language-server",
		"beautysh",
		"clang-format",
		"clangd",
		"css-lsp",
		"emmet-ls",
		"html-lsp",
		"htmlhint",
		"intelephense",
		"jq",
		"json-lsp",
		"jsonlint",
		"latexindent",
		"lua-language-server",
		"marksman",
		"mdformat",
		"oxlint",
		"ruff",
		"rust-analyzer",
		"stylelint",
		"tailwindcss-language-server",
		"texlab",
		"typescript-language-server",
		"shellcheck",
		"sqls",
		"sqlfluff",
	},
	auto_update = true,
	run_on_start = true,
})
