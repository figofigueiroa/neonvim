return {

  {
    "willothy/flatten.nvim",
    config = true,
    -- or pass configuration with
    -- opts = {  }
    -- Ensure that it runs first to minimize delay when opening file from terminal
    lazy = false,
    priority = 1001,
  },
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
  -- {
  --   "DrKJeff16/project.nvim",
  --   cmd = { "Project" }, -- Lazy-load by commands
  --   dependencies = { -- OPTIONAL. Choose any of the following
  --     "folke/snacks.nvim",
  --   },
  --   opts = {
  --     snacks = {
  --       -- Will enable the `:Project snacks` command
  --       enabled = true,
  --       opts = {
  --         sort = "newest",
  --         hidden = false,
  --         title = "Select Project",
  --         layout = "select",
  --         -- icon = {},
  --         -- path_icons = {},
  --       },
  --     },
  --   },
  -- },
}
