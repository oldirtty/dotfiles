return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep in files" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Find help" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Find keymaps" },
      { "<leader>fc", "<cmd>Telescope commands<CR>", desc = "Find commands" },
      {
        "<leader>fd",
        "<cmd>Telescope find_files cwd=~/.local/share/chezmoi<CR>",
        desc = "Find dotfiles",
      },
    },
    config = function()
      require("telescope").setup({})
      require("telescope").load_extension("fzf")
    end,
  },

  {
    "echasnovski/mini.files",
    version = "*",
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open()
        end,
        desc = "Explore files",
      },
    },
    init = function()
      -- Open mini.files instead of an empty buffer when nvim is started on a directory
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local dir = vim.fn.argv(0)
          if vim.fn.argc() == 1 and vim.fn.isdirectory(dir) == 1 then
            require("mini.files").open(dir)
          end
        end,
      })
    end,
    opts = {
      mappings = {
        -- netrw-style navigation: Enter opens file/enters dir, - goes up a level
        go_in = "",
        go_in_plus = "<CR>",
        go_out = "",
        go_out_plus = "-",
      },
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = {
        no_overlap = true,
      },
      -- Don't show the popup right after pressing d/y alone (e.g. "dd", "yy"
      -- still execute instantly); only defer-show once a second key follows
      defer = function(ctx)
        if vim.list_contains({ "d", "y", "c" }, ctx.operator) then
          return true
        end
        return vim.list_contains({ "<C-V>", "V" }, ctx.mode)
      end,
      spec = {
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Code" },
        { "<leader>r", group = "Rename" },
        { "<leader>b", group = "Buffer" },
        { "<leader>s", group = "Split" },
        { "<leader><tab>", group = "Tab" },
        { "<leader>e", desc = "Explore files" },
        { "<leader>L", desc = "Open Lazy" },
        { "<leader>H", desc = "Open dashboard" },
      },
    },
  },

  {
    "NMAC427/guess-indent.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}

