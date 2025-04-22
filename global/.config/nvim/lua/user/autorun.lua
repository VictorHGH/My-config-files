local commands = {
	python = "python3 %",
	javascript = "node %",
	php = "php %",
	lua = "lua %",
	sh = "bash %",
	rust = "rustc % && ./main",
	cpp = "g++ % -o main && ./main",
}

for ft, cmd in pairs(commands) do
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft,
		callback = function()
			vim.keymap.set("n", "<localleader>r", function()
				vim.cmd("vs | term " .. cmd)
				vim.cmd("startinsert")
			end, { buffer = true, desc = "Run current file in terminal" })
		end,
	})
end
