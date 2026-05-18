local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

local plugin_modules = {
	"completion",
	"editor",
	"git",
	"lsp",
	"navigation",
	"tools",
	"treesitter",
	"ui",
}

local plugins = {}
for _, module in ipairs(plugin_modules) do
	vim.list_extend(plugins, require("user.plugins." .. module))
end

local opts = {
	rocks = {
		enabled = false,
	},
}

require("lazy").setup(plugins, opts)
