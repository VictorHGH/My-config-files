local capabilities = require("user.LSP.common").capabilities

return {
	capabilities = capabilities,
	filetypes = {
		"html", "css", "scss",
		"javascript", "javascriptreact",
		"typescript", "typescriptreact", "php",
	},
}
