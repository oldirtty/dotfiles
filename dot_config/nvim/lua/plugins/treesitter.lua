return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "c",
        "cpp",
        "toml",
        "yaml",
        "kdl",
        "markdown",
        "markdown_inline",
        "json",
      }

      local installed = require("nvim-treesitter.config").get_installed()
      local to_install = vim.iter(ensure_installed)
        :filter(function(lang)
          return not vim.tbl_contains(installed, lang)
        end)
        :totable()

      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      -- Highlighting and indent are enabled per-buffer via autocmd,
      -- since the new API dropped the old highlight/indent opts
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ensure_installed,
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
