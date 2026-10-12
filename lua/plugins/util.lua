return {

  -- {
  --   "willothy/flatten.nvim",
  --   -- event = "TermOpen",
  --   config = true,
  --   -- or pass configuration with
  --   -- opts = {  }
  --   -- Ensure that it runs first to minimize delay when opening file from terminal
  --   lazy = false,
  --   priority = 1001,
  -- },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- só começa a rastrear quando você abre um arquivo
    opts = {
      need = 1, -- só salva se houver ao menos 1 buffer de arquivo
      -- branch = true, -- opcional: uma sessão por branch do git
    },
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Select Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
  {
    "figofigueiroa/rest.nvim",
    ft = { "http" },
    keys = {
      { "<leader>R", "", desc = "+Rest" },
      { "<leader>Re", "<cmd>Rest env select<cr>", desc = "Select environment", ft = "http" },
      { "<leader>Ro", "<cmd>Rest open<cr>", desc = "Open result pane", ft = "http" },
      { "<leader>Rr", "<cmd>Rest run<cr>", desc = "Send the request", ft = "http" },
      { "<leader>RR", "<cmd>Rest last<cr>", desc = "Replay the last request", ft = "http" },
      { "<leader>Rv", "<cmd>Rest vars select<cr>", desc = "Select vars for http session", ft = "http" },
      { "<leader>Rl", "<cmd>Rest vars list<cr>", desc = "List vars for http session", ft = "http" },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "http")
        table.insert(opts.ensure_installed, "graphql")
      end,
    },
  },
}
