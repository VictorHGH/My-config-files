local ts = require("nvim-treesitter")

ts.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

ts.install({
	"bash", "css", "html", "javascript", "ninja", "markdown", "python", "scss", "tsx", "typescript",
	"lua", "astro", "json", "htmldjango", "http", "csv", "php", "cpp", "c", "c_sharp", "vim", "yaml",
	"dockerfile", "ssh_config", "blade",
}, { summary = false })
