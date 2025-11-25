local configs = require("nvim-treesitter.configs")

configs.setup({
	ensure_installed = {
		"bash",
		"css",
		"html",
		"javascript",
		"ninja",
		"markdown",
		"python",
		"scss",
		"tsx",
		"typescript",
		"lua",
		"astro",
		"json",
		"htmldjango",
		"http",
		"csv",
		"php",
		"cpp",
		"c",
		"c_sharp",
		"vim",
		"yaml",
		"dockerfile",
		"ssh_config",
		"sql",
	},

	modules = {}, -- Nuevo campo (normalmente vacío)
	auto_install = false,

	sync_install = false,
	ignore_install = { "" },

	highlight = {
		enable = true,
		disable = { "" },
		additional_vim_regex_highlighting = true,
	},

	indent = { enable = true },
	ts_context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	autopairs = { enable = true },
})
