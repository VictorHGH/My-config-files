-- Configuración general de LSP y diagnóstico en Neovim

local lsp_format = require("lsp-format")
local lspconfig = require("lspconfig")

-- Habilitar soporte para snippets
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Configuración global del sistema de diagnósticos
vim.diagnostic.config({
	virtual_text = {
		prefix = "●", -- Cambia si quieres otro ícono aquí
	},
	signs = false,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		focusable = false,
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- Mostrar tooltip automático al dejar el cursor sobre un error
vim.o.updatetime = 3000
vim.cmd([[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

-- Lista de servidores LSP con sus configuraciones
local servers = {
	astro = {},
	bashls = {},
	clangd = {},
	cssls = {},
	emmet_ls = {
		filetypes = {
			"html", "css", "scss",
			"javascript", "javascriptreact",
			"typescript", "typescriptreact", "php",
		}
	},
	html = {
		filetypes = { "html" },
		settings = {
			html = {
				format = {
					indentInnerHtml = true
				}
			}
		}
	},
	phpactor = {
		format = {
			indent_inner_html = true
		}
	},
	marksman = {},
	ruff = {},
	rust_analyzer = {},
	tailwindcss = {},
	texlab = {},
	ts_ls = {},
}

-- Setup de cada servidor
for server, config in pairs(servers) do
	config.on_attach = function(client, bufnr)
		-- Habilita lsp-format
		lsp_format.on_attach(client, bufnr)

		-- Formateo automático al guardar
		if client.server_capabilities.documentFormattingProvider then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ async = false })
				end,
			})
		end

		-- keymaps por buffer se definen aquí
	end

	config.capabilities = capabilities
	lspconfig[server].setup(config)
end

