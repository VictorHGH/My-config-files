local supermaven_status_ok, supermaven = pcall(require, "supermaven-nvim")
if not supermaven_status_ok then
	return
end

supermaven.setup({
	keymaps = {
		accept_suggestion = "<C-l>",
		clear_suggestion = "<C-]>",
		accept_word = "<C-k>",
	}
})
