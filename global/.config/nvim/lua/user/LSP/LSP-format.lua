local lsp_format = require("lsp-format")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
local lspconfig = require("lspconfig")

local servers = {
	astro = {},
	bashls = {},
	clangd = {},
	cssls = {},
	emmet_ls = {
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"php"
		}
	},
	html = {
		filetypes = { "html" },
		-- setting for indentInnerHtml:
		settings = {
			html = {
				format = {
					indentInnerHtml = true
				}
			}
		}
	},
	-- phpactor con innnerHtml
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

for server, config in pairs(servers) do
	config.on_attach = function(client)
		lsp_format.on_attach(client)
	end
	config.capabilities = capabilities
	lspconfig[server].setup(config)
end

local signs = { Error = "X", Warn = " ", Hint = "!", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.diagnostic.config()
end
