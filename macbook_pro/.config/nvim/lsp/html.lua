local capabilities = require("user.LSP.common").capabilities

return {
	capabilities = capabilities,
	filetypes = { "html" },
	settings = {
		html = {
			format = { indentInnerHtml = true },
		},
	},
}
