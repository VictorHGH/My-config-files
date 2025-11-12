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
	"nvim-tree/nvim-web-devicons",
	"nvim-tree/nvim-tree.lua",
	"AndrewRadev/tagalong.vim",
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {}
	},

	-- ColorSheme
	"ellisonleao/gruvbox.nvim",

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
	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp"
	},
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
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"JoosepAlviste/nvim-ts-context-commentstring",
	"wuelnerdotexe/vim-astro",

	-- Git
	"lewis6991/gitsigns.nvim",

	-- Lualine
	"nvim-lualine/lualine.nvim",

	-- Floaterm
	"voldikss/vim-floaterm",

	-- Github supermaven
	"supermaven-inc/supermaven-nvim",

	-- Easymotion
	"easymotion/vim-easymotion",

	-- Vimwiki
	"vimwiki/vimwiki",

	-- Rest client
	"rest-nvim/rest.nvim",

	-- SQL UI for Neovim
	'tpope/vim-dadbod',
	'kristijanhusak/vim-dadbod-ui',

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},

	-- Folding
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			-- Opciones generales para folds
			vim.o.foldcolumn = "1" -- Muestra una columna con indicadores de folds
			vim.o.foldlevel = 99 -- Mantiene todos los folds abiertos por defecto
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Configuración de nvim-ufo
			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "lsp", "indent" } -- Usa LSP primero, luego indentación
				end,

			})
		end
		-- zR = Expande todos los folds
		-- zM = Contrae todos los folds
		-- zO = Abre los folds abiertos
		-- zC = Cierra todos los folds
		-- za = Muestra los folds abiertos
		-- zo = Muestra los folds cerrados
		-- zr = Muestra los folds recursivos
		-- zm = Muestra los folds más grandes
		-- zx = Muestra los folds recursivos más grandes
	},
}

local opts = {}

require("lazy").setup(plugins, opts)
