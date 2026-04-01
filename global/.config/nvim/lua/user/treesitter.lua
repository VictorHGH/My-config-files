local ts = require("nvim-treesitter")
local parsers = {
	"bash", "css", "html", "javascript", "ninja", "markdown", "python", "scss", "tsx", "typescript",
	"astro", "json", "htmldjango", "http", "csv", "php", "cpp", "c", "c_sharp", "vim", "yaml",
	"dockerfile", "ssh_config", "blade",
}

ts.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

local missing = {}

local site_parser_dir = vim.fn.stdpath("data") .. "/site/parser"
local site_lua_parser = site_parser_dir .. "/lua.so"
local runtime_lua_parser = vim.env.VIMRUNTIME .. "/parser/lua.so"

if vim.fn.filereadable(runtime_lua_parser) == 1 then
	if vim.fn.filereadable(site_lua_parser) == 0
		or vim.fn.getftime(runtime_lua_parser) > vim.fn.getftime(site_lua_parser) then
		vim.fn.mkdir(site_parser_dir, "p")
		pcall(vim.uv.fs_copyfile, runtime_lua_parser, site_lua_parser)
	end
end

for _, parser in ipairs(parsers) do
	local ok = vim.treesitter.language.add(parser)
	if not ok then
		table.insert(missing, parser)
	end
end

if #missing > 0 then
	ts.install(missing, { summary = false })
end
