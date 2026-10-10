local U = require("config.utils")

return {
  {
    "olimorris/codecompanion.nvim",
    enabled = U.is_win(),
    lazy = true,
    event = "LazyFile",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ravitemer/codecompanion-history.nvim",
      "cairijun/codecompanion-agentskills.nvim",
    },
    opts = {
      interactions = {
        cli = {
          agent = "copilot",
        },
        chat = {
          adapter = "copilot",
          slash_commands = {
            ["file"] = { opts = { provider = "snacks" } },
            ["buffer"] = { opts = { provider = "snacks" } },
            ["help"] = { opts = { provider = "snacks" } },
            ["symbols"] = { opts = { provider = "snacks" } },
            ["workspace"] = { opts = { provider = "snacks" } },
            ["image"] = { opts = { provider = "snacks" } },
            ["mcp"] = { opts = { provider = "snacks" } },
          },
        },
      },
      display = {
        action_palette = {
          provider = "snacks",
        },
      },
      extensions = {
        history = {
          enabled = true,
          opts = {
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion_chats.json",
            auto_generate_title = true,
            title_generation_opts = {
              adapter = "copilot",
            },
          },
        },
        agentskills = {
          opts = {
            paths = {
              { "~/.config/nvim/skills", recursive = true },
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>aa",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion: Action Palette",
      },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion: Toggle Chat" },
      {
        "<leader>as",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = "v",
        desc = "CodeCompanion: Add Selection to Chat",
      },
      {
        "<leader>af",
        "<cmd>CodeCompanionChat Changes<cr>",
        mode = "n",
        desc = "CodeCompanion: Changed Files",
      },
      {
        "<leader>ai",
        ":CodeCompanion ",
        mode = { "n", "v" },
        silent = false,
        desc = "CodeCompanion: Inline Prompt",
      },
      { "<leader>al", "<cmd>CodeCompanionCLI<cr>", mode = "n", desc = "CodeCompanion: Open CLI" },
      {
        "<leader>ax",
        function()
          return require("codecompanion").cli("#{this}", { focus = false })
        end,
        mode = { "n", "v" },
        desc = "CodeCompanion: Add Context to CLI",
      },
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
  {
    "folke/sidekick.nvim",
    opts = function()
      -- Accept inline suggestions or next edits
      U.actions.ai_nes = function()
        local Nes = require("sidekick.nes")
        if Nes.have() and (Nes.jump() or Nes.apply()) then
          return true
        end
      end
      Snacks.toggle({
        name = "Sidekick NES",
        get = function()
          return require("sidekick.nes").enabled
        end,
        set = function(state)
          require("sidekick.nes").enable(state)
        end,
      }):map("<leader>uN")
    end,
    -- stylua: ignore
    keys = vim.list_extend({
      -- nes is also useful in normal mode
      { "<tab>",     U.map({ "ai_nes" }, "<tab>"), mode = { "n" }, expr = true },
      { "<leader>a", "",                           desc = "[A]i",  mode = { "n", "v" } },
    }, not U.is_win() and {
      {
        "<c-.>",
        function() require("sidekick.cli").focus() end,
        desc = "Sidekick Focus",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select() end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = "Select CLI",
      },
      {
        "<leader>ad",
        function() require("sidekick.cli").close() end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    } or {}),
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local sk = U.opts("sidekick.nvim")
      if vim.tbl_get(sk, "nes", "enabled") ~= false then
        opts.servers = opts.servers or {}
        opts.servers.copilot = opts.servers.copilot or {}
      end
    end,
  },
}
