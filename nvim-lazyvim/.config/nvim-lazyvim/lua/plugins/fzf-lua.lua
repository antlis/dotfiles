-- AI bot
return {
  {
    "ibhagwan/fzf-lua",
    -- Ensure fzf-lua is loaded
    lazy = false,
    config = function()
      require("fzf-lua").setup({
        winopts = {
          fullscreen = true, -- Always open in full screen
        },
      })
    end,
  },
}
