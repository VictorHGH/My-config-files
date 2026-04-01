local health = vim.health or require("health")

local M = {}

function M.check()
	local report_start = health.start or health.report_start
	local report_ok = health.ok or health.report_ok

	report_start("mason.nvim")
	report_ok("Mason is available. Optional language runtimes are managed outside Neovim in this setup.")
end

return M
