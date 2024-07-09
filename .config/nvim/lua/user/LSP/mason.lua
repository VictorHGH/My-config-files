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
		"astro-language-server",
		"bash-language-server",
		"beautysh",
		"biome",
		"clang-format",
		"clangd",
		"css-lsp",
		"djlint",
		"emmet-ls",
		"html-lsp",
		"htmlbeautifier",
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
		"pretty-php",
		"ruff",
		"ruff-lsp",
		"rust-analyzer",
		"stylelint",
		"tailwindcss-language-server",
		"texlab",
		"typescript-language-server",
	},
	auto_update = true,
	run_on_start = true,
})
