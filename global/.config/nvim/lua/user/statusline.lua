local function git_branch()
	local branch = vim.b.gitsigns_head
	if branch and branch ~= "" then
		return " " .. branch
	end
	return ""
end

local function diagnostics()
	local counts = vim.diagnostic.count(0)
	local errors = counts[vim.diagnostic.severity.ERROR] or 0
	local warnings = counts[vim.diagnostic.severity.WARN] or 0

	local parts = {}
	if errors > 0 then
		table.insert(parts, "E" .. errors)
	end
	if warnings > 0 then
		table.insert(parts, "W" .. warnings)
	end

	if #parts == 0 then
		return ""
	end

	return " " .. table.concat(parts, " ")
end

local function os_icon()
	if vim.fn.has("mac") == 1 then
		return "mac"
	elseif vim.fn.has("win32") == 1 then
		return "win"
	end
	return "linux"
end

function _G.user_statusline()
	return table.concat({
		" ",
		"%f",
		"%m%r",
		git_branch(),
		diagnostics(),
		"%=",
		"%{&fileencoding?&fileencoding:&encoding}",
		" ",
		os_icon(),
		" ",
		"%y",
		" ",
		"%p%%",
		" ",
		"%l:%c ",
	})
end

vim.opt.statusline = "%!v:lua.user_statusline()"
