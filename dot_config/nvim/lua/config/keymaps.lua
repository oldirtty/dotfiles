local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move between splits with Ctrl+hjkl
map("n", "<C-h>", "<C-w>h", { desc = "Go to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right split" })

-- Resize splits with arrows
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase split height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease split height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease split width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase split width" })

-- Buffer navigation (<S-h>/<S-l> now provided by bufferline.nvim, plugins/ui.lua)

-- Buffer group under <leader>b (same actions, discoverable via which-key)
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bb", "<cmd>Telescope buffers<CR>", { desc = "List buffers" })

-- Split group under <leader>s
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sc", "<cmd>close<CR>", { desc = "Close split" })
map("n", "<leader>so", "<cmd>only<CR>", { desc = "Close other splits" })

-- Tab navigation
map("n", "<leader><tab>n", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader><tab>c", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "]<tab>", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "[<tab>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

-- Save with Ctrl+S (common IDE convention, works in normal and insert mode)
map({ "n", "i" }, "<C-s>", "<cmd>write<CR>", { desc = "Save file" })

-- Open Lazy plugin manager
map("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Open Lazy" })

