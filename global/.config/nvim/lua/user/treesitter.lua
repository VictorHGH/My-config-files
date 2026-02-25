local ts = require("nvim-treesitter")
local parsers = {
	"bash", "css", "html", "javascript", "ninja", "markdown", "python", "scss", "tsx", "typescript",
	"lua", "astro", "json", "htmldjango", "http", "csv", "php", "cpp", "c", "c_sharp", "vim", "yaml",
	"dockerfile", "ssh_config", "blade",
}

ts.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

local installed = ts.get_installed("parsers")
local installed_set = {}
for _, parser in ipairs(installed) do
	installed_set[parser] = true
end

local missing = {}
for _, parser in ipairs(parsers) do
	if not installed_set[parser] then
		table.insert(missing, parser)
	end
end

if #missing > 0 then
	ts.install(missing, { summary = false })
end
