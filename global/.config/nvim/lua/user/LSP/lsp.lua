-- lua/user/LSP/lsp.lua

-- 1) Diagnósticos globales
require("user.LSP.common").setup_diagnostics()

-- 2) Conectar on_attach a TODOS los LSP
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspOnAttach", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end

		-- Ejemplo: desactivar formato en ciertos servers
		-- if client.name == "ts_ls" then
		--   client.server_capabilities.documentFormattingProvider = false
		-- end

		require("user.LSP.on_attach").setup(client, bufnr)
	end,
})

-- 3) Habilitar servidores
local servers = {
	-- sin overrides: no requieren archivo en lsp/
	"astro", "bashls", "clangd", "cssls", "marksman", "ruff",
	"rust_analyzer", "tailwindcss", "texlab", "ts_ls",

	-- con overrides: necesitas sus archivos en lsp/
	"emmet_ls", "html", "lua_ls", "phpactor",
}

for _, name in ipairs(servers) do
	vim.lsp.enable(name)
end
