vim.cmd([[imap <silent><script><expr> <C-l> copilot#Accept("\<CR>")]])
vim.g.copilot_no_tab_map = true
vim.keymap.set('i', '<C-k>', '<Plug>(copilot-accept-word)')
vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)')

-- Ctrl-l to accepts the current completion
-- Ctrl + k to accept the current word
-- Ctrl + j to go to the next completion
