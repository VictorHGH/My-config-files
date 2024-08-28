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

-- Install your plugins here
local plugins = {
	-- My plugins here
	"nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins
	"windwp/nvim-autopairs", -- Autopairs integrates with both cmp and treesitter
	"numToStr/Comment.nvim", -- Easily comment stuff
	"kyazdani42/nvim-web-devicons",
	"kyazdani42/nvim-tree.lua",
	"AndrewRadev/tagalong.vim",
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {}
	},

	-- ColorSheme
	"morhetz/gruvbox",

	-- Vimtex
	"lervag/vimtex",

	-- cmp plugins
	"hrsh7th/nvim-cmp",      -- The completion plugin
	"hrsh7th/cmp-buffer",    -- buffer completions
	"hrsh7th/cmp-path",      -- path completions
	"hrsh7th/cmp-cmdline",   -- cmdline completions
	"saadparwaiz1/cmp_luasnip", -- snippet completions
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-nvim-lua",

	-- snippets
	"L3MON4D3/LuaSnip",
	"rafamadriz/friendly-snippets",

	-- LSP
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig",
	"lukas-reineke/lsp-format.nvim",
	"WhoIsSethDaniel/mason-tool-installer.nvim",

	-- Telescope
	"nvim-telescope/telescope.nvim",

	-- Tresitter
	"nvim-treesitter/nvim-treesitter",
	"JoosepAlviste/nvim-ts-context-commentstring",
	"wuelnerdotexe/vim-astro",

	-- Git
	"lewis6991/gitsigns.nvim",

	-- Lualine
	"nvim-lualine/lualine.nvim",

	-- Floaterm
	"voldikss/vim-floaterm",

	-- Github copilot
	"github/copilot.vim",

	-- Easymotion
	"easymotion/vim-easymotion",

	-- Vimwiki
	"vimwiki/vimwiki",

	-- Codi.vim
	"metakirby5/codi.vim",

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
		build = "cd app && yarn install",
	},
}

local opts = {}

require("lazy").setup(plugins, opts)
