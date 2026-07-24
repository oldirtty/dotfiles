return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "lua_ls", "clangd", "taplo" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- mason-lspconfig automatically enables (vim.lsp.enable) installed servers,
      -- so lua_ls/clangd/taplo need no manual setup here

      -- kdl-lsp is not on Mason and has no nvim-lspconfig default;
      -- install manually (cargo install kdl-lsp or AUR). Diagnostics only for now.
      if vim.fn.executable("kdl-lsp") == 1 then
        vim.lsp.config("kdl_lsp", {
          cmd = { "kdl-lsp" },
          filetypes = { "kdl" },
          root_markers = { ".git" },
        })
        vim.lsp.enable("kdl_lsp")
      end

      -- Keymaps on LSP attach (buffer-local, only active where LSP is running)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gr", vim.lsp.buf.references, "Goto references")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
        end,
      })
    end,
  },
}