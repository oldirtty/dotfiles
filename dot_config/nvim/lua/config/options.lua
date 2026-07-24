local opt = vim.opt

-- Disable netrw: mini.files (plugins/editor.lua) handles directory browsing instead
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Indentation: default 4 spaces, autodetected per-file by guess-indent.nvim
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Splits open in the intuitive direction
opt.splitright = true
opt.splitbelow = true

-- Persistent undo across sessions
opt.undofile = true

-- Use system clipboard for yank/delete/paste
opt.clipboard = "unnamedplus"

-- Keep sign column visible to avoid text shifting on lint/git changes
opt.signcolumn = "yes"

-- Show whitespace and indent markers (listchars); actual indent guide
-- rendering is handled by the indent-blankline plugin in plugins/ui.lua
opt.list = true
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Transparent background: let the terminal's background show through
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  end,
})
