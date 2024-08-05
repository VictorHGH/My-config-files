local function setup_autorun_execution()
	vim.api.nvim_command("augroup exe_code")
	vim.api.nvim_command("autocmd!")

	-- Python3
	vim.api.nvim_command(
		"autocmd Filetype python nnoremap <buffer> <localleader>r :vs<CR>:term python3 %<CR>:startinsert<CR>"
	)
	-- JavaScript
	vim.api.nvim_command(
		"autocmd Filetype javascript nnoremap <buffer> <localleader>r :vs<CR>:term node %<CR>:startinsert<CR>"
	)
	-- Bash
	vim.api.nvim_command(
		"autocmd Filetype sh nnoremap <buffer> <localleader>r :vs<CR>:term bash %<CR>:startinsert<CR>")
	-- Rust
	vim.api.nvim_command(
		"autocmd Filetype rust nnoremap <buffer> <localleader>r :vs<CR>:term rustc % && ./main<CR>:startinsert<CR>")
	-- C++
	vim.api.nvim_command(
		"autocmd Filetype cpp nnoremap <buffer> <localleader>r :vs<CR>:term g++ % -o main && ./main<CR>:startinsert<CR>")

	vim.api.nvim_command("augroup END")
end

-- Call the function to set up the autocmds
setup_autorun_execution()
