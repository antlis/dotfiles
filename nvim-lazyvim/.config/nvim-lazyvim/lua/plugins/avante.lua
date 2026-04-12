-- Helper function to get colors from the current colorscheme
local function get_colors()
  local fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg or "#ABB2BF"
  local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg or "#1E222A"
  local float_bg = vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg or bg
  local comment_fg = vim.api.nvim_get_hl(0, { name = "Comment" }).fg or "#5C6370"
  local keyword_fg = vim.api.nvim_get_hl(0, { name = "Keyword" }).fg or "#C678DD"
  local string_fg = vim.api.nvim_get_hl(0, { name = "String" }).fg or "#98C379"
  local number_fg = vim.api.nvim_get_hl(0, { name = "Number" }).fg or "#D19A66"
  local type_fg = vim.api.nvim_get_hl(0, { name = "Type" }).fg or "#E5C07B"
  local error_fg = vim.api.nvim_get_hl(0, { name = "Error" }).fg or "#E06C75"
  local warning_fg = vim.api.nvim_get_hl(0, { name = "WarningMsg" }).fg or "#E5C07B"

  return {
    fg = fg,
    bg = bg,
    float_bg = float_bg,
    comment_fg = comment_fg,
    keyword_fg = keyword_fg,
    string_fg = string_fg,
    number_fg = number_fg,
    type_fg = type_fg,
    error_fg = error_fg,
    warning_fg = warning_fg,
  }
end

-- Apply custom highlights to match the current colorscheme
local function apply_avante_highlights()
  local colors = get_colors()

  local highlights = {
    { "AvanteSidebarNormal", link = "NormalFloat" },
    { "AvanteSidebarWinSeparator", link = "FloatBorder" },
    { "AvanteSidebarWinHorizontalSeparator", link = "WinSeparator" },
    { "AvantePopupHint", link = "NormalFloat" },
    { "AvantePromptInputBorder", link = "FloatBorder" },

    { "AvanteTitle", fg = colors.bg, bg = colors.string_fg },
    { "AvanteSubtitle", fg = colors.bg, bg = colors.keyword_fg },
    { "AvanteThirdTitle", fg = colors.comment_fg, bg = colors.bg },

    { "AvanteButtonDefault", fg = colors.bg, bg = colors.comment_fg },
    { "AvanteButtonDefaultHover", fg = colors.bg, bg = colors.string_fg },
    { "AvanteButtonPrimary", fg = colors.bg, bg = colors.comment_fg },
    { "AvanteButtonPrimaryHover", fg = colors.bg, bg = colors.keyword_fg },
    { "AvanteButtonDanger", fg = colors.bg, bg = colors.comment_fg },
    { "AvanteButtonDangerHover", fg = colors.bg, bg = colors.error_fg },

    { "AvanteStateSpinnerGenerating", fg = colors.bg, bg = colors.keyword_fg },
    { "AvanteStateSpinnerToolCalling", fg = colors.bg, bg = colors.keyword_fg },
    { "AvanteStateSpinnerFailed", fg = colors.bg, bg = colors.error_fg },
    { "AvanteStateSpinnerSucceeded", fg = colors.bg, bg = colors.string_fg },
    { "AvanteStateSpinnerSearching", fg = colors.bg, bg = colors.keyword_fg },
    { "AvanteStateSpinnerThinking", fg = colors.bg, bg = colors.keyword_fg },

    { "AvanteTaskRunning", fg = colors.keyword_fg, bg = colors.bg },
    { "AvanteTaskCompleted", fg = colors.string_fg, bg = colors.bg },
    { "AvanteTaskFailed", fg = colors.error_fg, bg = colors.bg },

    { "AvanteConflictCurrent", bg = colors.error_fg, bold = true },
    { "AvanteConflictIncoming", bg = colors.keyword_fg, bold = true },

    { "AvanteSuggestion", link = "Comment" },
    { "AvanteAnnotation", link = "Comment" },
    { "AvanteInlineHint", link = "Keyword" },
    { "AvanteThinking", fg = colors.keyword_fg, bg = colors.bg },
    { "AvanteReversedNormal", fg = colors.fg, bg = colors.bg },
  }

  for _, hl in ipairs(highlights) do
    local name = hl[1]
    local opts = {}
    if hl.link then opts.link = hl.link end
    if hl.fg then opts.fg = hl.fg end
    if hl.bg then opts.bg = hl.bg end
    if hl.bold then opts.bold = hl.bold end
    vim.api.nvim_set_hl(0, name, opts)
  end
end

return {
  {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    opts = {
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          -- model = "claude-sonnet-4-20250514",
          model = "claude-opus-4-6",
          api_key_name = "ANTHROPIC_API_KEY",
          extra_request_body = {
            max_tokens = 8192,
          },
        },
        nanogpt = {
          __inherited_from = "openai",
          endpoint = "https://nano-gpt.com/api/v1",
          api_key_name = "NANOGPT_API_KEY",
          model = "minimax/minimax-m2.5",
          -- model = 'zai-org/glm-5',
        },
      },
      windows = {
        sidebar_header = {
          enabled = false,
        },
      },
      selection = {
        hint_display = "none",
      },
      behaviour = {
        auto_set_keymaps = false,
      },
    },
    config = function(_, opts)
      require("avante").setup(opts)

      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
        callback = function()
          apply_avante_highlights()
        end,
      })

      vim.schedule(apply_avante_highlights)
    end,
    cmd = {
      "AvanteAsk",
      "AvanteBuild",
      "AvanteChat",
      "AvanteClear",
      "AvanteEdit",
      "AvanteFocus",
      "AvanteHistory",
      "AvanteModels",
      "AvanteRefresh",
      "AvanteShowRepoMap",
      "AvanteStop",
      "AvanteSwitchProvider",
      "AvanteToggle",
    },
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<CR>",            desc = "Ask Avante" },
      { "<leader>ac", "<cmd>AvanteChat<CR>",           desc = "Chat with Avante" },
      { "<leader>ae", "<cmd>AvanteEdit<CR>",           desc = "Edit Avante" },
      { "<leader>af", "<cmd>AvanteFocus<CR>",          desc = "Focus Avante" },
      { "<leader>ah", "<cmd>AvanteHistory<CR>",        desc = "Avante History" },
      { "<leader>am", "<cmd>AvanteModels<CR>",         desc = "Select Avante Model" },
      { "<leader>an", "<cmd>AvanteChatNew<CR>",        desc = "New Avante Chat" },
      { "<leader>ap", "<cmd>AvanteSwitchProvider<CR>", desc = "Switch Avante Provider" },
      { "<leader>ar", "<cmd>AvanteRefresh<CR>",        desc = "Refresh Avante" },
      { "<leader>as", "<cmd>AvanteStop<CR>",           desc = "Stop Avante" },
      { "<leader>at", "<cmd>AvanteToggle<CR>",         desc = "Toggle Avante" },
    },
  },
}
