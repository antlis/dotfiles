return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            width = { padding = 0 },
            height = { padding = 0 },
            preview_width = 0.5,
          },
        },
        border = false,
      },
    },
  },
}
