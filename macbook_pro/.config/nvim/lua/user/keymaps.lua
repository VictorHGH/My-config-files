-- Mapas de teclas generales

local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Redefinir espacio como tecla <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("", "<Space>", "<Nop>", opts)

-- Normal mode --
-- Navegación entre ventanas
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Guardar y salir rápido
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Guardar archivo" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Cerrar buffer" })

-- Navegación visual mejorada (soporte para líneas largas)
vim.keymap.set("n", "j", "gj", opts)
vim.keymap.set("n", "k", "gk", opts)
vim.keymap.set("n", "gj", "j", opts)
vim.keymap.set("n", "gk", "k", opts)

-- Abrir explorador de archivos
vim.keymap.set("n", "<leader>nt", ":NvimTreeOpen<CR>", { desc = "Abrir árbol de archivos" })

-- Redimensionar splits con teclas intuitivas
vim.keymap.set("n", "<C-w>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-s>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-f>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-a>", ":vertical resize +2<CR>", opts)

-- Navegación entre buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Buffer siguiente" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Buffer anterior" })

-- Visual mode --
-- Indentación persistente
vim.keymap.set("n", "<Tab>", ">>", opts)
vim.keymap.set("n", "<S-Tab>", "<<", opts)
vim.keymap.set("v", "<Tab>", ">gv", opts)
vim.keymap.set("v", "<S-Tab>", "<gv", opts)

-- Mover líneas seleccionadas arriba/abajo
vim.keymap.set("v", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("v", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("v", "p", '"_dP', opts) -- pegar sin sobrescribir el registro

-- Visual block --
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)
vim.keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
vim.keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal mode --
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- LazyGit con Floaterm
vim.keymap.set("n", "<leader><leader>l", ":FloatermNew --height=0.9 --width=0.9 lazygit<CR>", { desc = "Abrir LazyGit" })
vim.keymap.set("n", "<leader>T", ":FloatermNew --height=0.9 --width=0.9<CR>", { desc = "New terminal" })

-- Activar/desactivar spell check
vim.keymap.set("n", "<leader><leader>o", ":set spell<CR>", { desc = "Activar spellcheck" })
vim.keymap.set("n", "<leader><leader>O", ":set nospell<CR>", { desc = "Desactivar spellcheck" })

-- Telescope --
vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Buscar archivos" })
vim.keymap.set("n", "<C-t>", "<cmd>Telescope live_grep<CR>", { desc = "Buscar texto en archivos" })
vim.keymap.set("n", "<leader>lD", "<cmd>Telescope diagnostics<CR>", { desc = "Diagnósticos globales" })
vim.keymap.set("n", "<leader>ld", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Diagnósticos del buffer actual" })
