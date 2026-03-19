return {
  "gruvw/strudel.nvim",
  build = "npm ci",
  config = function()
    require("strudel").setup({
      ui = {
        maximise_menu_panel = true,
        hide_top_bar = false,
        hide_code_editor = false,
      },

      -- ui = {
      --     hide_menu_panel = false,
      --     hide_top_bar = false,
      --     hide_error_display = false,
      --     hide_code_editor = false,
      --     -- set `hide_code_editor = false` if you want to overlay the code editor
      -- },

      start_on_launch = true,
      update_on_save = true,   -- auto eval on :w
      sync_cursor = true,
      report_eval_errors = true,
    })

    -- Keymaps
    -- local strudel = require("strudel")
    -- vim.keymap.set("n", "<leader>sl", strudel.launch,     { desc = "Launch Strudel" })
    -- vim.keymap.set("n", "<leader>sq", strudel.quit,       { desc = "Quit Strudel" })
    -- vim.keymap.set("n", "<leader>st", strudel.toggle,     { desc = "Toggle Play/Stop" })
    -- vim.keymap.set("n", "<leader>su", strudel.update,     { desc = "Update/Eval Code" })
    -- vim.keymap.set("n", "<leader>ss", strudel.stop,       { desc = "Stop Playback" })
    -- vim.keymap.set("n", "<leader>sb", strudel.set_buffer, { desc = "Set Strudel Buffer" })
    -- vim.keymap.set("n", "<leader>sx", strudel.execute,    { desc = "Set Buffer + Update" })
  end,
}
