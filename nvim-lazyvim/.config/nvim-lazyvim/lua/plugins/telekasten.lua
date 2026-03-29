return {
  {
    "renerocksai/telekasten.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
      -- "mattn/calendar-vim",  -- add this
    },
    config = function()
      local home = vim.fn.expand("~/Documents/vault")

      require("telekasten").setup({
        home      = home,
        dailies   = home .. "/journal",
        templates = home .. "/templates",
      })

      local tk = require("telekasten")

      local function daily_path(d)
        local month_name = os.date("%B", os.time(d))
        local month_dir  = string.format("%02d_%s", d.month, month_name)
        local fname      = string.format("%04d-%02d-%02d.md", d.year, d.month, d.day)
        return string.format("%s/journal/%04d/%s/%s", home, d.year, month_dir, fname)
      end

      local function open_daily(d)
        local path = daily_path(d)
        vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
        vim.cmd("edit " .. vim.fn.fnameescape(path))
      end

      tk.goto_today = function()
        open_daily(os.date("*t"))
      end

      tk.find_daily_notes = function()
        require("telescope.builtin").find_files({
          prompt_title = "Daily Notes",
          cwd          = home .. "/journal",
          find_command = {
            "find", ".", "-type", "f",
            "-name", "????-??-??.md",
            "-not", "-name", "*.sync-conflict-*",
          },
        })
      end

      tk.goto_date = function(date_str)
        local y, m, d = date_str:match("(%d%d%d%d)-(%d%d)-(%d%d)")
        if y then
          open_daily({ year = tonumber(y), month = tonumber(m), day = tonumber(d) })
        end
      end
    end,
  },
}
