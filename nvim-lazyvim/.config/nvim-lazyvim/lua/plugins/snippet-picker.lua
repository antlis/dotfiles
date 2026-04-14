local function get_snippets()
  local snippets = {}
  local snippet_dir = vim.fn.stdpath("config") .. "/snippets"
  local files = vim.fn.glob(snippet_dir .. "/*.json", false, true)

  for _, file in ipairs(files) do
    local basename = vim.fn.fnamemodify(file, ":t:r")
    if basename == "package" then
      goto continue
    end

    local ok, content = pcall(vim.fn.readfile, file)
    if not ok then
      goto continue
    end

    local decoded = vim.json.decode(table.concat(content, "\n"))
    if decoded then
      for name, snippet in pairs(decoded) do
        local prefix = type(snippet.prefix) == "table" and snippet.prefix[1] or snippet.prefix
        local body = type(snippet.body) == "table" and table.concat(snippet.body, "\n") or snippet.body
        table.insert(snippets, {
          name = name,
          prefix = prefix,
          body = body,
          description = snippet.description or "",
          source = basename,
        })
      end
    end

    ::continue::
  end

  table.sort(snippets, function(a, b)
    if a.source ~= b.source then
      return a.source < b.source
    end
    return a.prefix < b.prefix
  end)

  return snippets
end

local function insert_snippet(snippet)
  if vim.snippet and vim.snippet.expand then
    vim.snippet.expand(snippet.body)
  else
    -- Fallback: insert without expanding placeholders
    local lines = vim.split(snippet.body, "\n", { plain = true })
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, lines)
  end
end

local function pick_snippets()
  local snippets = get_snippets()
  if #snippets == 0 then
    vim.notify("No snippets found", vim.log.levels.WARN)
    return
  end

  local fzf = require("fzf-lua")
  local entries = {}
  local lookup = {}

  for _, s in ipairs(snippets) do
    local entry = string.format("[%s] %s  ─  %s", s.source, s.prefix, s.description)
    table.insert(entries, entry)
    lookup[entry] = s
  end

  fzf.fzf_exec(entries, {
    prompt = "Snippets❯ ",
    preview = function(selected)
      if not selected or #selected == 0 then
        return ""
      end
      local s = lookup[selected[1]]
      if not s then
        return ""
      end
      local lines = {}
      table.insert(lines, "Name:   " .. s.name)
      table.insert(lines, "Prefix: " .. s.prefix)
      table.insert(lines, "Source: " .. s.source)
      table.insert(lines, "")
      table.insert(lines, "─── body ───")
      for _, line in ipairs(vim.split(s.body, "\n", { plain = true })) do
        table.insert(lines, line)
      end
      return lines
    end,
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        local s = lookup[selected[1]]
        if s then
          vim.schedule(function()
            insert_snippet(s)
          end)
        end
      end,
      ["ctrl-y"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        local s = lookup[selected[1]]
        if s then
          vim.fn.setreg("+", s.body)
          vim.notify("Copied: " .. s.prefix, vim.log.levels.INFO)
        end
      end,
    },
  })
end

return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>sS", pick_snippets, desc = "Snippets" },
    },
  },
}
