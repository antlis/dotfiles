return {
  "antlis/telescope-gist",
  dependencies = {
    {
      "nvim-telescope/telescope.nvim",
      cmd = "Telescope", -- ensure :Telescope is registered as a lazy-load trigger
      dependencies = { "nvim-lua/plenary.nvim" },
    },
  },
  config = function()
    require("telescope-gist").setup({})
    require("telescope").load_extension("gist")
  end,
  keys = {
    { "<leader>gG", "<cmd>Telescope gist list<cr>", desc = "Gist List" },
    { "<leader>gn", ":GistCreate<CR>", desc = "Create Gist", mode = { "n", "v" } },
  },
}
