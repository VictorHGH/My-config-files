vim.cmd([[imap <silent><script><expr> <C-a> copilot#Accept("\<CR>")]])
vim.g.copilot_no_tab_map = true
-- Ctrl-a to accepts the current completion
-- win + ] to go to the next completion
