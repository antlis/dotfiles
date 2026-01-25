-- ~/.config/nvim/lua/plugins/gp.lua
return {
  {
    "Robitx/gp.nvim",
    config = function()
      require("gp").setup({

        -- 🔑 Providers
        providers = {
          -- Hugging Face Providers API (new router endpoint)
          hf_router = {
            endpoint = "https://router.huggingface.co/v1/chat/completions",
            secret = os.getenv("HF_API_KEY"), -- your free HF API key
          },

          -- Optional: Local DeepSeek if you want local code completions
          --[[
          localdeepseek = {
            endpoint = "http://localhost:11434/v1/chat/completions",
          },
          ]]
        },

        -- 🧑‍💻 Agents
        agents = {
          -- Chat agent using HF router
          {
            name = "HFAIChat",
            provider = "hf_router",
            model = "meta-llama/Llama-3.1-8B-Instruct",
            system_prompt = "You are a helpful assistant.",
            chat = true,
            command = true,
          },

          -- Optional local code agent (DeepSeek) for offline coding
          --[[
          {
            name = "LocalDeepSeek",
            provider = "localdeepseek",
            model = "deepseek-r1", -- local model
            system_prompt = "You are an expert software engineer. Answer with correct, production-ready code.",
            chat = true,
            command = true,
          },
          ]]
        },

        -- 🏆 Default agents
        default_chat_agent = "HFAIChat",
        default_command_agent = "HFAIChat",

        -- Optional: Adjust response display for Neovim
        max_response_lines = 50, -- limits very long responses in the buffer
      })

      -- Optional: keymaps for ease of use
      local map = vim.keymap.set
      -- Open new chat buffer
      map("n", "<leader>ac", ":GpChatNew<CR>", { desc = "Open AI Chat" })
      -- Explain selected code
      map("v", "<leader>ae", ":GpExplain<CR>", { desc = "Explain code with AI" })
      -- Rewrite selected code
      map("v", "<leader>ar", ":GpRewrite<CR>", { desc = "Rewrite code with AI" })
    end,
  },
}
