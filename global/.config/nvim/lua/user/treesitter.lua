local ts = require("nvim-treesitter")
local parsers = {
	"bash", "css", "html", "javascript", "ninja", "markdown", "python", "scss", "tsx", "typescript",
	"astro", "json", "htmldjango", "http", "csv", "php", "cpp", "c", "c_sharp", "vim", "yaml",
	"dockerfile", "ssh_config", "blade",
}

local parser_by_filetype = {
	cs = "c_sharp",
	sh = "bash",
	sshconfig = "ssh_config",
	typescriptreact = "tsx",
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

for filetype, parser in pairs(parser_by_filetype) do
	vim.treesitter.language.register(parser, filetype)
end

if #missing > 0 then
	ts.install(missing, { summary = false })
end

local filetypes = vim.deepcopy(parsers)
local enabled_filetypes = {}

for _, filetype in ipairs(filetypes) do
	enabled_filetypes[filetype] = true
end

for filetype in pairs(parser_by_filetype) do
	table.insert(filetypes, filetype)
	enabled_filetypes[filetype] = true
end

local function start_treesitter(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if enabled_filetypes[vim.bo[bufnr].filetype] then
		pcall(vim.treesitter.start, bufnr)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = function()
		start_treesitter()
	end,
})

for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
	if vim.api.nvim_buf_is_loaded(bufnr) then
		start_treesitter(bufnr)
	end
end
