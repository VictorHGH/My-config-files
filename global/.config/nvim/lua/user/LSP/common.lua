-- lua/user/LSP/common.lua
local M = {}

-- Capacidades (snippets)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = capabilities

-- Diagnóstico global
function M.setup_diagnostics()
	vim.diagnostic.config({
		virtual_text = { prefix = "●" },
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
	vim.o.updatetime = 3000
	vim.api.nvim_create_autocmd("CursorHold", {
		callback = function()
			vim.diagnostic.open_float(nil, { focusable = false })
		end,
	})
end

return M
