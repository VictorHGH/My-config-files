-- function to upgrade nvim running this commands: 'lazy update' and 'TSUpdate'
local function upgrade_nvim()
	vim.cmd("TSUpdate")
	vim.cmd("MasonUpdate")
	require("lazy").update()
end

vim.api.nvim_create_user_command("UpgradeNvim", upgrade_nvim, {})
