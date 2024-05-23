local lsp_format = require("lsp-format")
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
local lspconfig = require("lspconfig")

local servers = {
	tsserver = {},
	biome = {},
	emmet_ls = {},
	html = {},
	cssls = {},
	tailwindcss = {},
	astro = {},
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" }
				}
			}
		}
	},
	pylsp = {},
	clangd = {},
	bashls = {},
	texlab = {},
	marksman = {},
	rust_analyzer = {},
	intelephense = {},
}

for server, config in pairs(servers) do
	config.on_attach = function(client)
		lsp_format.on_attach(client)
	end
	config.capabilities = capabilities
	lspconfig[server].setup(config)
end

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
