local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Leader ----------------------------------------------------------------------
-- <leader> and <localleader> are both Space.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("", "<Space>", "<Nop>", opts)

-- Windows ---------------------------------------------------------------------
-- Move between splits.
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize splits.
vim.keymap.set("n", "<leader>+", ":resize +2<CR>", { desc = "Aumentar alto de ventana" })
vim.keymap.set("n", "<leader>-", ":resize -2<CR>", { desc = "Reducir alto de ventana" })
vim.keymap.set("n", "<leader><", ":vertical resize -2<CR>", { desc = "Reducir ancho de ventana" })
vim.keymap.set("n", "<leader>>", ":vertical resize +2<CR>", { desc = "Aumentar ancho de ventana" })

-- Files and buffers -----------------------------------------------------------
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Guardar archivo" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Cerrar buffer" })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Buffer siguiente" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Buffer anterior" })
vim.keymap.set("n", "<leader>nt", ":NvimTreeOpen<CR>", { desc = "Abrir arbol de archivos" })

-- Wrapped-line movement.
vim.keymap.set("n", "j", "gj", opts)
vim.keymap.set("n", "k", "gk", opts)
vim.keymap.set("n", "gj", "j", opts)
vim.keymap.set("n", "gk", "k", opts)

-- Editing ---------------------------------------------------------------------
vim.keymap.set("n", "<Tab>", ">>", opts)
vim.keymap.set("n", "<S-Tab>", "<<", opts)
vim.keymap.set("v", "<Tab>", ">gv", opts)
vim.keymap.set("v", "<S-Tab>", "<gv", opts)
vim.keymap.set("v", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("v", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("v", "p", '"_dP', opts) -- Paste without overwriting the register.
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Native comments -------------------------------------------------------------
-- Neovim provides these by default: gcc comments current line, gc{motion}
-- comments a motion, and visual gc comments the selection. gcb is kept as an
-- alias for the previous muscle memory; native commenting has no separate
-- block-comment operator.
vim.keymap.set("n", "gcb", "gcc", { remap = true, silent = true, desc = "Comment current line" })
vim.keymap.set("x", "gcb", "gc", { remap = true, silent = true, desc = "Comment selection" })

-- Native movement replacing EasyMotion ----------------------------------------
-- / and ? search forward/backward, n/N repeat search, * and # search word under
-- cursor, f/F/t/T jump within the current line, ; and , repeat those jumps, and
-- % jumps between matching pairs.

-- Terminal --------------------------------------------------------------------
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

local function open_terminal(command)
	vim.cmd("botright split")
	vim.cmd("resize 15")
	vim.fn.termopen(command or vim.o.shell)
	vim.cmd("startinsert")
end

local function open_terminal_tab(command)
	vim.cmd("tabnew")
	vim.bo.bufhidden = "wipe"
	vim.fn.termopen(command or vim.o.shell)
	vim.api.nvim_create_autocmd("TermClose", {
		buffer = 0,
		once = true,
		callback = function(args)
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(args.buf) then
					vim.cmd("silent! tabclose")
				end
			end)
		end,
	})
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader><leader>l", function()
	open_terminal_tab({ "lazygit" })
end, { desc = "Abrir LazyGit" })
vim.keymap.set("n", "<leader>T", function()
	open_terminal()
end, { desc = "New terminal" })

-- Spell -----------------------------------------------------------------------
vim.keymap.set("n", "<leader><leader>o", ":set spell<CR>", { desc = "Activar spellcheck" })
vim.keymap.set("n", "<leader><leader>O", ":set nospell<CR>", { desc = "Desactivar spellcheck" })

-- Telescope -------------------------------------------------------------------
vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Buscar archivos" })
vim.keymap.set("n", "<C-t>", "<cmd>Telescope live_grep<CR>", { desc = "Buscar texto en archivos" })
vim.keymap.set("n", "<leader>lD", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnósticos globales" })
vim.keymap.set("n", "<leader>ld", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Diagnósticos del buffer actual" })

-- Folds -----------------------------------------------------------------------
-- Native fold keys kept from Vim/Neovim:
-- za toggles the fold under cursor, zo opens it, zc closes it, zR opens all,
-- zM closes all, zr opens one level recursively, and zm closes one level.

-- Plugin-local keymaps documented here ----------------------------------------
-- LSP keymaps are attached per buffer in lua/user/LSP/on_attach.lua:
-- gl diagnostic float, gd definition, gi implementation, gr references,
-- K hover, <leader>rn rename, <leader>ca code action.
-- Gitsigns keymaps are attached per git buffer in lua/user/gitsigns.lua:
-- ]c/[c next/previous hunk, <leader>hs stage hunk, <leader>hr reset hunk,
-- <leader>hS stage buffer, <leader>hu undo stage hunk, <leader>hR reset buffer,
-- <leader>hp preview hunk, <leader>hb blame line, <leader>tb toggle blame,
-- <leader>hd diff this, <leader>hD diff against previous, <leader>td deleted.
