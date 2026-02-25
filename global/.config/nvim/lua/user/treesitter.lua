local ts = require("nvim-treesitter")
local parsers = {
	"bash", "css", "html", "javascript", "ninja", "markdown", "python", "scss", "tsx", "typescript",
	"lua", "astro", "json", "htmldjango", "http", "csv", "php", "cpp", "c", "c_sharp", "vim", "yaml",
	"dockerfile", "ssh_config", "blade",
}

ts.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

local missing = {}
for _, parser in ipairs(parsers) do
	local ok = vim.treesitter.language.add(parser)
	if not ok then
		table.insert(missing, parser)
	end
end

if #missing > 0 then
	ts.install(missing, { summary = false })
end
