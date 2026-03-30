return {
  -- add emoji source to blink.cmp
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = vim.list_extend(opts.sources.default or {}, { "emoji" })
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.emoji = {
        module = "blink.compat.source",
        name = "emoji",
        opts = { trigger = ":" },
      }
    end,
  },

  -- keep cmp-emoji as the data source (blink.compat bridges it)
  {
    "hrsh7th/cmp-emoji",
    dependencies = { "saghen/blink.compat" },
    event = "InsertEnter",
  },

  {
    "xiyaowong/telescope-emoji.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").setup({
        extensions = {
          emoji = {
            action = function(emoji)
              local mode = vim.fn.mode()
              vim.api.nvim_put({ emoji.value }, "c", false, true)
              if mode == "i" then
                vim.cmd("startinsert!")
              end
            end,
          },
        },
      })
      require("telescope").load_extension("emoji")
      vim.keymap.set("n", "<leader>se", function()
        require("telescope").extensions.emoji.emoji()
      end, { desc = "[S]earch [E]moji" })
    end,
  },
}
