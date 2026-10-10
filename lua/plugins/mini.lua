-- Monorepo mini.nvim: 1 plugin = 1 config. No lazy.nvim, fragments do mesmo repo
-- mesclam num plugin só (keys/event se unem; config de fragment anterior é
-- sombreado) — não splitar em vários fragments com config.
-- ponytail: defer por módulo além do mini.files exigiria placeholder keymaps;
-- o statusline define o piso (UIEnter) e os demais módulos são baratos.
local debug_mode = require("config.utils").debug_mode
local U = require("config.utils")

return {
  "nvim-mini/mini.nvim",
  event = "UIEnter",
  config = function()
    local statusline = require("mini.statusline")

    local function mode_section(trunc_width)
      local is_normal = vim.fn.mode() == "n"
      if debug_mode.enabled and is_normal then
        local text = statusline.is_truncated(trunc_width) and "D" or "Debug"
        return text, "MiniStatuslineModeDebug"
      end
      return statusline.section_mode({ trunc_width = trunc_width })
    end

    statusline.setup({
      content = {
        active = function()
          local mode, mode_hl = mode_section(120)
          local git = statusline.section_git({ trunc_width = 40 })
          local diff = statusline.section_diff({ trunc_width = 75 })
          local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
          local lsp = statusline.section_lsp({ trunc_width = 75 })
          local filename = statusline.section_filename({ trunc_width = 140 })
          local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
          local location = statusline.section_location({ trunc_width = 75 })
          local search = statusline.section_searchcount({ trunc_width = 75 })

          -- LSP progress nativo (Neovim 0.10+)
          local lsp_progress = vim.lsp.status()
          if lsp_progress ~= "" then
            lsp_progress = " " .. lsp_progress
          end

          return statusline.combine_groups({
            { hl = mode_hl, strings = { mode } },
            { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp, spinner } },
            "%<", -- truncate point
            { hl = "MiniStatuslineFilename", strings = { filename } },
            "%=", -- right align
            { hl = "MiniStatuslineFileinfo", strings = { lsp_progress, fileinfo } },
            { hl = mode_hl, strings = { search, location } },
          })
        end,
      },
    })

    require("mini.statuscolumn").setup()
    local ai = require("mini.ai")
    local ai_opts = {
      n_lines = 500,
      custom_textobjects = {
        o = ai.gen_spec.treesitter({ -- code block
          a = { "@block.outer", "@conditional.outer", "@loop.outer" },
          i = { "@block.inner", "@conditional.inner", "@loop.inner" },
        }),
        f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        d = { "%f[%d]%d+" },
        e = {
          { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
          "^().*()$",
        },
        g = U.mini.ai_buffer,
        u = ai.gen_spec.function_call(),
        U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
      },
    }
    ai.setup(ai_opts)
    U.on_load("which-key.nvim", function()
      vim.schedule(function()
        U.mini.ai_whichkey(ai_opts)
      end)
    end)
    require("mini.pairs").setup({
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    })
    require("mini.jump").setup()
    require("mini.surround").setup({
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    })
    require("mini.icons").setup()
    require("mini.pick").setup()
  end,
  keys = {
    {
      "<leader>e",
      function()
        if _G.MiniFiles == nil then
          require("mini.files").setup()
        end
        require("mini.files").open()
      end,
      desc = "Explorer (mini.files)",
    },
  },
}
