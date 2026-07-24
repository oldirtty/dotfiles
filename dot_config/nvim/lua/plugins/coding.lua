return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "super-tab",
        -- The super-tab preset only maps Tab to snippet jumps; add list
        -- cycling explicitly so Tab/S-Tab also step through completion items
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
      },
      completion = {
        -- Nothing preselected: Enter only accepts an item you've navigated to,
        -- otherwise it just inserts a newline
        list = { selection = { preselect = false } },
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      signature = { enabled = true },
    },
  },
}

