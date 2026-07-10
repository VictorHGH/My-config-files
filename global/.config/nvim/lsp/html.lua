local capabilities = require("user.LSP.common").capabilities

return {
	capabilities = capabilities,
	filetypes = { "html", "blade" },
	settings = {
		html = {
			format = { indentInnerHtml = true },
		},
	},
}
