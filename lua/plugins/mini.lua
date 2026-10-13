-- mini.nvim em repos standalone (nvim-mini/mini.*): 1 módulo = 1 spec = 1 trigger.
-- Piso: statusline/statuscolumn/pick precisam existir quando a UI desenha (UIEnter);
-- pick seta vim.ui.select no setup — deferir deixaria selects iniciais na UI default.
-- ponytail: ai/jump/pairs em VeryLazy/InsertEnter — deferir por keymap exigiria
-- placeholders para ~30 textobjects e teclas quentes (f/F/t/T); carregam logo após a UI.
local U = require("config.utils")
local debug_mode = U.debug_mode

return {
  {
    "nvim-mini/mini.statusline",
    event = "LazyFile",
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

      -- marcadores de raiz vindos de vim.g.root_spec (options.lua);
      -- "lsp"/"cwd" são detectors, não padrões de arquivo/diretório
      local root_markers = {}
      for _, spec in ipairs(vim.g.root_spec or {}) do
        if type(spec) == "table" then
          vim.list_extend(root_markers, spec)
        end
      end

      -- nome da raiz do projeto + caminho relativo a ela; sem marcador acima → absoluto
      local function filename_section(args)
        if vim.bo.buftype == "terminal" then
          return "%t"
        elseif statusline.is_truncated(args.trunc_width) then
          return "%f%m%r"
        end
        local path = vim.api.nvim_buf_get_name(0)
        local root = path ~= "" and vim.fs.root(path, root_markers)
        local rel = root and vim.fs.relpath(root, path)
        local file = (rel and (vim.fs.basename(root) .. "/" .. rel) or path):gsub("%%", "%%%%")
        return file ~= "" and file .. "%m%r" or "%F%m%r"
      end

      statusline.setup({
        content = {
          active = function()
            local mode, mode_hl = mode_section(120)
            local git = statusline.section_git({ trunc_width = 40 })
            local diff = statusline.section_diff({ trunc_width = 75 })
            local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
            local lsp = statusline.section_lsp({ trunc_width = 75 })
            -- rest.nvim: variáveis selecionadas (:Rest vars select); o guard de
            -- filetype evita carregar o plugin (lazy ft=http) fora de buffers http
            local rest = vim.bo.filetype == "http" and require("rest-nvim.variaveis").statusline() or ""
            local filename = filename_section({ trunc_width = 140 })
            local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
            local location = statusline.section_location({ trunc_width = 75 })
            local search = statusline.section_searchcount({ trunc_width = 75 })

            return statusline.combine_groups({
              { hl = mode_hl,                 strings = { mode } },
              { hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics, lsp } },
              "%<", -- truncate point
              { hl = "MiniStatuslineFilename", strings = { filename } },
              "%=", -- right align
              { hl = "MiniStatuslineFileinfo", strings = { rest, fileinfo } },
              { hl = mode_hl,                  strings = { search, location } },
            })
          end,
        },
      })
    end,
  },
  {
    "nvim-mini/mini.statuscolumn",
    event = "LazyFile",
    config = function()
      require("mini.statuscolumn").setup()
    end,
  },
  {
    "nvim-mini/mini.ai",
    event = "LazyFile",
    config = function()
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
    end,
  },
  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter", -- pair no cmdline só após o 1º insert (teto: invisível na prática)
    config = function()
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
    end,
  },
  {
    "nvim-mini/mini.jump",
    event = "LazyFile",
    config = function()
      require("mini.jump").setup()
    end,
  },
  {
    "nvim-mini/mini.surround",
    keys = {
      { "gsa", mode = { "n", "x" } },
      { "gsd", mode = { "n", "x" } },
      { "gsf", mode = { "n", "x" } },
      { "gsF", mode = { "n", "x" } },
      { "gsh", mode = { "n", "x" } },
      { "gsr", mode = { "n", "x" } },
      { "gsn", mode = { "n", "x" } },
    },
    config = function()
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
    end,
  },
  {
    "nvim-mini/mini.files",
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
      {
        "-",
        function()
          if _G.MiniFiles == nil then
            require("mini.files").setup()
          end
          require("mini.files").open()
        end,
        desc = "Explorer (mini.files)",
      },
    },
  },
  {
    "nvim-mini/mini.icons",
    lazy = true, -- carrega junto com a dependency do bufferline (ui.lua)
    config = function()
      require("mini.icons").setup()
    end,
  },
}
