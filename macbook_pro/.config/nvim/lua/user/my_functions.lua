-- function to upgrade nvim running this commands: 'lazy update' and 'TSUpdate'
local function upgrade_nvim()
	require("lazy").update()
	vim.cmd("MasonUpdate")
end

vim.api.nvim_create_user_command("UpgradeNvim", upgrade_nvim, {})
