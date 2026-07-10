-- lua/user/LSP/on_attach.lua

local M = {}

local formatters_by_filetype = {
	c = { clangd = true },
	cpp = { clangd = true },
	css = { cssls = true },
	html = { html = true },
	json = { jsonls = true },
	jsonc = { jsonls = true },
	lua = { lua_ls = true },
	php = { phpactor = true },
	python = { ruff = true },
	rust = { rust_analyzer = true },
	scss = { cssls = true },
	tex = { texlab = true },
}

local function can_format(client, bufnr)
	if not client:supports_method("textDocument/formatting") then
		return false
	end

	local formatters = formatters_by_filetype[vim.bo[bufnr].filetype]
	return formatters ~= nil and formatters[client.name] == true
end

function M.setup(client, bufnr)
	if can_format(client, bufnr) then
		local grp = vim.api.nvim_create_augroup("LspFormatting_" .. bufnr, { clear = true })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = grp,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({
					async = false,
					bufnr = bufnr,
					filter = function(format_client)
						return format_client.name == client.name
					end,
				})
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
