return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        formats = {
          "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif",
          "mp4", "mov", "avi", "mkv", "webm", "pdf", "icns",
        },
        doc = {
          enabled = true,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
        img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments", "assets/images" },
        resolve = function(file, src)
          -- try relative to current file first
          local rel = vim.fn.fnamemodify(file, ":h") .. "/" .. src
          if vim.fn.filereadable(rel) == 1 then
            return rel
          end
          -- fallback: resolve from vault root
          local vault = vim.fn.expand("~/Documents/vault")
          local from_vault = vault .. "/" .. src
          if vim.fn.filereadable(from_vault) == 1 then
            return from_vault
          end
        end,
      },
      dashboard = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        formats = {
          key = function(item)
            return { { "[", hl = "special" }, { item.key, hl = "key" }, { "]", hl = "special" } }
          end,
        },
        sections = {
          { section = "keys", gap = 1, padding = 1 },
        },
      },
    },
    init = function()
      -- treat telekasten buffers as markdown for image rendering
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "telekasten",
        callback = function()
          vim.bo.filetype = "markdown"
        end,
      })
    end,
  },
}
