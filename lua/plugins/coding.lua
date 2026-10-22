local U = require("config.utils")

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "nvim-lspconfig",     words = { "lspconfig.settings" } },
        { path = "lazy.nvim",          words = { "LazyVim" } },
        { path = "snacks.nvim",        words = { "Snacks" } },
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    -- build = "cargo +nightly build --release",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "folke/lazydev.nvim",
    },
    opts = {
      keymap = {
        preset = "default",
        -- aceita inline completion do copilot (ai_accept) ou NES (ai_nes)
        ["<Tab>"] = { U.map({ "snippet_forward", "ai_nes", "ai_accept" }), "fallback" },
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        menu = {
          draw = {
            columns = {
              { "source_name" },
              { "label",      "label_description", gap = 1 },
              { "kind_icon",  "kind",              gap = 1 },
            },
          },
        },
      },

      sources = {
        default = { "lazydev", "lsp", "path", "snippets" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- above lsp, for require("...") completions
          },
          -- copilot = {
          --   name = 'copilot',
          --   module = 'blink-copilot',
          --   score_offset = 100,
          --   async = true,
          -- },
        },
      },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See `:help blink-cmp-config-fuzzy` for more information
      -- fuzzy = { implementation = "lua" },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    keys = {
      { "<leader>r", "", desc = "+refactor", mode = { "n", "x" } },
      {
        "<leader>rs",
        function()
          return require("refactoring").select_refactor()
        end,
        mode = { "n", "x" },
        desc = "Select Refactor",
      },
      {
        "<leader>ri",
        function()
          return require("refactoring").inline_var()
        end,
        mode = { "n", "x" },
        desc = "Inline Variable",
        expr = true,
      },
      {
        "<leader>rP",
        function()
          return require("refactoring.debug").print_loc({ output_location = "below" })
        end,
        desc = "Debug Print Location",
        expr = true,
      },
      {
        "<leader>rp",
        function()
          return require("refactoring.debug").print_var({ output_location = "below" }) .. "iw"
        end,
        mode = { "n", "x" },
        desc = "Debug Print Variable",
        expr = true,
      },
      {
        "<leader>rc",
        function()
          return require("refactoring.debug").cleanup({ restore_view = true }) .. "ag"
        end,
        desc = "Debug Cleanup",
        expr = true,
      },
      {
        "<leader>rf",
        function()
          return require("refactoring").extract_func()
        end,
        mode = { "n", "x" },
        desc = "Extract Function",
        expr = true,
      },
      {
        "<leader>rF",
        function()
          return require("refactoring").extract_func_to_file()
        end,
        mode = { "n", "x" },
        desc = "Extract Function To File",
        expr = true,
      },
      {
        "<leader>rx",
        function()
          return require("refactoring").extract_var()
        end,
        mode = { "n", "x" },
        desc = "Extract Variable",
        expr = true,
      },
    },
    opts = {},
  },
  {
    "monaqa/dial.nvim",
    keys = {
      {
        "<C-a>",
        function()
          return require("dial.map").inc_normal()
        end,
        expr = true,
        desc = "Increment",
      },
      {
        "<C-x>",
        function()
          return require("dial.map").dec_normal()
        end,
        expr = true,
        desc = "Decrement",
      },
      {
        "g<C-a>",
        function()
          return require("dial.map").inc_gnormal()
        end,
        expr = true,
        desc = "Increment",
      },
      {
        "g<C-x>",
        function()
          return require("dial.map").dec_gnormal()
        end,
        expr = true,
        desc = "Decrement",
      },
    },
    opts = function()
      local augend = require("dial.augend")

      local logical_alias = augend.constant.new({
        elements = { "&&", "||" },
        word = false,
        cyclic = true,
      })

      local ordinal_numbers = augend.constant.new({
        -- elements through which we cycle. When we increment, we go down
        -- On decrement we go up
        elements = {
          "first",
          "second",
          "third",
          "fourth",
          "fifth",
          "sixth",
          "seventh",
          "eighth",
          "ninth",
          "tenth",
        },
        -- if true, it only matches strings with word boundary. firstDate wouldn't work for example
        word = false,
        -- do we cycle back and forth (tenth to first on increment, first to tenth on decrement).
        -- Otherwise nothing will happen when there are no further values
        cyclic = true,
      })

      local months = augend.constant.new({
        elements = {
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December",
        },
        word = true,
        cyclic = true,
      })

      return {
        dials_by_ft = {
          css = "css",
          vue = "vue",
          javascript = "typescript",
          typescript = "typescript",
          typescriptreact = "typescript",
          javascriptreact = "typescript",
          json = "json",
          lua = "lua",
          markdown = "markdown",
          sass = "css",
          scss = "css",
          python = "python",
          csharp = "cs",
        },
        groups = {
          default = {
            augend.integer.alias.decimal,          -- nonnegative decimal number (0, 1, 2, 3, ...)
            augend.integer.alias.decimal_int,      -- nonnegative and negative decimal number
            augend.integer.alias.hex,              -- nonnegative hex number  (0x01, 0x1a1f, etc.)
            augend.date.alias["%d/%m/%Y"],         -- date (2022/02/19, etc.)
            augend.constant.alias.en_weekday,      -- Mon, Tue, ..., Sat, Sun
            augend.constant.alias.en_weekday_full, -- Monday, Tuesday, ..., Saturday, Sunday
            ordinal_numbers,
            months,
            augend.constant.alias.bool, -- boolean value (true <-> false)
            augend.constant.alias.Bool, -- boolean value (True <-> False)
            logical_alias,
          },
          vue = {
            augend.constant.new({ elements = { "let", "const" } }),
            augend.hexcolor.new({ case = "lower" }),
            augend.hexcolor.new({ case = "upper" }),
          },
          typescript = {
            augend.constant.new({ elements = { "let", "const" } }),
          },
          css = {
            augend.hexcolor.new({
              case = "lower",
            }),
            augend.hexcolor.new({
              case = "upper",
            }),
          },
          markdown = {
            augend.constant.new({
              elements = { "[ ]", "[~]", "[x]" },
              word = false,
              cyclic = true,
            }),
            augend.misc.alias.markdown_header,
          },
          json = {
            augend.semver.alias.semver, -- versioning (v1.1.2)
          },
          lua = {
            augend.constant.new({
              elements = { "and", "or" },
              word = true,   -- if false, "sand" is incremented into "sor", "doctor" into "doctand", etc.
              cyclic = true, -- "or" is incremented into "and".
            }),
          },
          python = {
            augend.constant.new({
              elements = { "and", "or" },
            }),
          },
        },
      }
    end,
    config = function(_, opts)
      -- copy defaults to each group
      for name, group in pairs(opts.groups) do
        if name ~= "default" then
          vim.list_extend(group, opts.groups.default)
        end
      end
      require("dial.config").augends:register_group(opts.groups)
      vim.g.dials_by_ft = opts.dials_by_ft
    end,
  },
  {
    "gbprod/yanky.nvim",
    desc = "Better Yank/Paste",
    event = "LazyFile",
    opts = {
      system_clipboard = {
        sync_with_ring = not vim.env.SSH_CONNECTION,
      },
      highlight = { timer = 150 },
    },
    keys = {
      {
        "<leader>p",
        function()
          Snacks.picker.yanky()
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
      -- stylua: ignore
      { "y",  "<Plug>(YankyYank)",                      mode = { "n", "x" },                           desc = "Yank Text" },
      { "p",  "<Plug>(YankyPutAfter)",                  mode = { "n", "x" },                           desc = "Put Text After Cursor" },
      { "P",  "<Plug>(YankyPutBefore)",                 mode = { "n", "x" },                           desc = "Put Text Before Cursor" },
      { "gp", "<Plug>(YankyGPutAfter)",                 mode = { "n", "x" },                           desc = "Put Text After Selection" },
      { "gP", "<Plug>(YankyGPutBefore)",                mode = { "n", "x" },                           desc = "Put Text Before Selection" },
      { "[y", "<Plug>(YankyCycleForward)",              desc = "Cycle Forward Through Yank History" },
      { "]y", "<Plug>(YankyCycleBackward)",             desc = "Cycle Backward Through Yank History" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put Indented After Cursor (Linewise)" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put Indented Before Cursor (Linewise)" },
      { "]P", "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put Indented After Cursor (Linewise)" },
      { "[P", "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put Indented Before Cursor (Linewise)" },
      { ">p", "<Plug>(YankyPutIndentAfterShiftRight)",  desc = "Put and Indent Right" },
      { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)",   desc = "Put and Indent Left" },
      { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
      { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)",  desc = "Put Before and Indent Left" },
      { "=p", "<Plug>(YankyPutAfterFilter)",            desc = "Put After Applying a Filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)",           desc = "Put Before Applying a Filter" },
    },
  }
}
