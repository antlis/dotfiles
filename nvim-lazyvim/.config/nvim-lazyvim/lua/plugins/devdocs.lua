return {
  {
    "luckasRanarison/nvim-devdocs",
    cmd = {
      "DevdocsFetch",
      "DevdocsInstall",
      "DevdocsUninstall",
      "DevdocsOpen",
      "DevdocsOpenFloat",
      "DevdocsOpenCurrent",
      "DevdocsOpenCurrentFloat",
      "DevdocsToggle",
      "DevdocsUpdate",
      "DevdocsUpdateAll",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    -- keys = {
    --   { "<leader>sd", "<cmd>DevdocsOpen<cr>", desc = "Search DevDocs" },
    -- },
  },
}
