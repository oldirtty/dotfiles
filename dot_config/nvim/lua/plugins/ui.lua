return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    opts = {
      styles = { transparency = true },
      -- Keep the statusline and bufferline solid even though the rest of the UI is transparent
      highlight_groups = {
        StatusLine = { bg = "surface" },
        StatusLineNC = { bg = "surface" },
        BufferLineFill = { bg = "surface" },
        Visual = { reverse = true },
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.cmd.colorscheme("rose-pine")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        -- Straight, square separators instead of powerline-style angled ones
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        -- Mode and diagnostics get their own sections so they stand out
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { "filename" },
        lualine_x = { "diagnostics" },
        lualine_y = { "filetype" },
        lualine_z = { "location" },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- Highlight only the current scope's indent (needs treesitter active
      -- in the buffer, see plugins/treesitter.lua); others stay dimmed.
      -- show_start/show_end off: no underline at the top/bottom of the block
      scope = { enabled = true, show_start = false, show_end = false },
    },
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
    },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        show_close_icon = false,
        always_show_bufferline = false,
      },
    },
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      {
        "<leader>H",
        function()
          Snacks.dashboard()
        end,
        desc = "Open dashboard",
      },
    },
    opts = {
      dashboard = { enabled = true },
      notifier = { enabled = true },
    },
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      -- Cmdline rendered as a centered popup instead of the bottom line
      cmdline = {
        view = "cmdline_popup",
        format = {
          cmdline = { icon = ":" },
          search_down = { icon = "/" },
          search_up = { icon = "?" },
        },
      },
      -- snacks.notifier already owns vim.notify; avoid two systems fighting over it
      notify = { enabled = false },
      messages = { view_search = false },
    },
  },
}
