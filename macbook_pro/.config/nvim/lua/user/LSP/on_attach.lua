-- lua/user/LSP/on_attach.lua
local lsp_format = require("lsp-format")

local M = {}

function M.setup(client, bufnr)
	lsp_format.on_attach(client, bufnr)

	-- Mejor práctica: supports_method
	if client.supports_method("textDocument/formatting") then
		local grp = vim.api.nvim_create_augroup("LspFormatting_" .. bufnr, { clear = true })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = grp,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ async = false })
			end,
		})
	end

	-- Mappings LSP específicos del buffer
	local opts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

return M
