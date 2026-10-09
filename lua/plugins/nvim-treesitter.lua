local U = require("config.utils")

return { {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  version = false, -- last release is way too old and doesn't work on Windows
  build = function()
    local TS = require("nvim-treesitter")
    if not TS.get_installed then
      vim.notify("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.", "error")
      return
    end
    -- make sure we're using the latest treesitter util
    package.loaded["config.utils"] = nil
    U.build(function()
      TS.update(nil, { summary = true })
    end)
  end,
  event = { "LazyFile", "VeryLazy" },
  cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
  opts_extend = { "ensure_installed" },
  opts = {
    -- LazyVim config for treesitter
    indent = { enable = true },
    highlight = { enable = true },
    folds = { enable = true },
    ensure_installed = {
      "bash",
      "c",
      "diff",
      "html",
      "javascript",
      "jsdoc",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "printf",
      "python",
      "query",
      "regex",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    },
  },
  config = function(_, opts)
    local TS = require("nvim-treesitter")

    setmetatable(require("nvim-treesitter.install"), {
      __newindex = function(_, k)
        if k == "compilers" then
          vim.schedule(function()
            vim.notify({
              "Setting custom compilers for `nvim-treesitter` is no longer supported.",
              "",
              "For more info, see:",
              "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
            }, vim.log.levels.ERROR)
          end)
        end
      end,
    })

    -- some quick sanity checks
    if not TS.get_installed then
      return vim.notify("Please use `:Lazy` and update `nvim-treesitter`", vim.log.levels.ERROR)
    elseif type(opts.ensure_installed) ~= "table" then
      return vim.notify("`nvim-treesitter` opts.ensure_installed must be a table", vim.log.levels.ERROR)
    end

    -- setup treesitter
    TS.setup(opts)
    U.get_installed(true) -- initialize the installed langs

    -- install missing parsers
    local install = vim.tbl_filter(function(lang)
      return not U.have(lang)
    end, opts.ensure_installed or {})
    if #install > 0 then
      U.build(function()
        TS.install(install, { summary = true }):await(function()
          U.get_installed(true) -- refresh the installed langs
        end)
      end)
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
      callback = function(ev)
        local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
        if not U.have(ft) then
          return
        end

        ---@param feat string
        ---@param query string
        local function enabled(feat, query)
          local f = opts[feat] or {}
          return f.enable ~= false
              and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang))
              and U.have(ft, query)
        end

        -- highlighting
        if enabled("highlight", "highlights") then
          pcall(vim.treesitter.start, ev.buf)
        end

        -- indents
        if enabled("indent", "indents") then
          vim.bo[ev.buf].indentexpr = "v:lua.require'config.utils'.indentexpr()"
        end

        -- folds
        if enabled("folds", "folds") then
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr = "v:lua.require'config.utils'.foldexpr()"
        end
      end,
    })
  end,
} }
