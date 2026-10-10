-- ícones de diagnóstico
local icons = {
  Error = "",
  Warn = "",
  Hint = "󰌵",
  Info = "󰋽",
}

local U = require("config.utils")

local status = {} ---@type table<number, "ok" | "error" | "pending">

return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts_extend = { "servers.*.keys" },
    opts = function()
      local ret = {
        -- opções para vim.diagnostic.config()
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = "●",
          },
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = icons.Error,
              [vim.diagnostic.severity.WARN] = icons.Warn,
              [vim.diagnostic.severity.HINT] = icons.Hint,
              [vim.diagnostic.severity.INFO] = icons.Info,
            },
          },
        },
        inlay_hints = {
          enabled = true,
          exclude = { "vue" }, -- filetypes sem inlay hints
        },
        codelens = {
          enabled = false,
        },
        folds = {
          enabled = true,
        },
        -- LSP Server Settings
        -- mason = false desativa instalação via mason; keys = keymaps extras
        servers = {
          -- configuração para todos os lsp servers
          ["*"] = {
            capabilities = {
              workspace = {
                fileOperations = {
                  didRename = true,
                  willRename = true,
                },
              },
            },
            keys = {
              {
                "<leader>cl",
                function()
                  Snacks.picker.lsp_config()
                end,
                desc = "Lsp Info",
              },
              {
                "gd",
                vim.lsp.buf.definition,
                desc = "Goto Definition",
                has = "definition",
              },
              {
                "gr",
                vim.lsp.buf.references,
                desc = "References",
                nowait = true,
              },
              { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
              { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
              { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
              {
                "K",
                function()
                  return vim.lsp.buf.hover()
                end,
                desc = "Hover",
              },
              {
                "gK",
                function()
                  return vim.lsp.buf.signature_help()
                end,
                desc = "Signature Help",
                has = "signatureHelp",
              },
              {
                "<c-k>",
                function()
                  return vim.lsp.buf.signature_help()
                end,
                mode = "i",
                desc = "Signature Help",
                has = "signatureHelp",
              },
              {
                "<leader>ca",
                vim.lsp.buf.code_action,
                desc = "Code Action",
                mode = { "n", "x" },
                has = "codeAction",
              },
              {
                "<leader>cc",
                vim.lsp.codelens.run,
                desc = "Run Codelens",
                mode = { "n", "x" },
                has = "codeLens",
              },
              {
                "<leader>cC",
                vim.lsp.codelens.refresh,
                desc = "Refresh & Display Codelens",
                mode = { "n" },
                has = "codeLens",
              },
              {
                "<leader>cR",
                function()
                  Snacks.rename.rename_file()
                end,
                desc = "Rename File",
                mode = { "n" },
                has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
              },
              {
                "<leader>cr",
                vim.lsp.buf.rename,
                desc = "Rename",
                has = "rename",
              },
              -- { "<leader>cA", LazyVim.lsp.action.source,                          desc = "Source Action",              has = "codeAction" },
              {
                "]]",
                function()
                  Snacks.words.jump(vim.v.count1)
                end,
                has = "documentHighlight",
                desc = "Next Reference",
                enabled = function()
                  return Snacks.words.is_enabled()
                end,
              },
              {
                "[[",
                function()
                  Snacks.words.jump(-vim.v.count1)
                end,
                has = "documentHighlight",
                desc = "Prev Reference",
                enabled = function()
                  return Snacks.words.is_enabled()
                end,
              },
              {
                "<a-n>",
                function()
                  Snacks.words.jump(vim.v.count1, true)
                end,
                has = "documentHighlight",
                desc = "Next Reference",
                enabled = function()
                  return Snacks.words.is_enabled()
                end,
              },
              {
                "<a-p>",
                function()
                  Snacks.words.jump(-vim.v.count1, true)
                end,
                has = "documentHighlight",
                desc = "Prev Reference",
                enabled = function()
                  return Snacks.words.is_enabled()
                end,
              },
              -- {
              --   "<leader>co",
              --   LazyVim.lsp.action["source.organizeImports"],
              --   desc = "Organize Imports",
              --   has = "codeAction",
              --   enabled = function(buf)
              --     local code_actions = vim.tbl_filter(function(action)
              --       return action:find("^source%.organizeImports%.?$")
              --     end, LazyVim.lsp.code_actions({ bufnr = buf }))
              --     return #code_actions > 0
              --   end
              -- },
            },
          },
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = "Replace",
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
          copilot = {
            keys = {
              {
                "<M-]>",
                function()
                  vim.lsp.inline_completion.select({ count = 1 })
                end,
                desc = "Next Copilot Suggestion",
                mode = { "i", "n" },
              },
              {
                "<M-[>",
                function()
                  vim.lsp.inline_completion.select({ count = -1 })
                end,
                desc = "Prev Copilot Suggestion",
                mode = { "i", "n" },
              },
            },
          },
        },
        -- setup customizado: function(server, opts) -> true pular o setup automático
        setup = {
          copilot = function()
            vim.schedule(function()
              vim.lsp.inline_completion.enable()
            end)
            -- Accept inline suggestions or next edits
            U.actions.ai_accept = function()
              return vim.lsp.inline_completion.get()
            end

            if not U.is_loaded("sidekick.nvim") then
              vim.lsp.config("copilot", {
                handlers = {
                  didChangeStatus = function(err, res, ctx)
                    if err then
                      return
                    end
                    status[ctx.client_id] = res.kind ~= "Normal" and "error" or res.busy and "pending" or "ok"
                    if res.status == "Error" then
                      vim.notify("Please use `:LspCopilotSignIn` to sign in to Copilot", vim.log.levels.ERROR)
                    end
                  end,
                },
              })
            end
          end,
        },
      }
      return ret
    end,
    config = function(_, opts)
      -- keymaps buffer-local + inlay hints + folds + codelens
      -- (port de lazyvim.plugins.lsp.keymaps + Snacks.util.lsp.on)
      local names = vim.tbl_keys(opts.servers) ---@type string[]
      table.sort(names)

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end

          -- keymaps: server "*" vale para qualquer client; gate por `has`/`enabled`
          for _, server in ipairs(names) do
            local sopts = opts.servers[server]
            if type(sopts) == "table" and sopts.keys and (server == "*" or client.name == server) then
              for _, key in ipairs(sopts.keys) do
                local methods = type(key.has) == "table" and key.has or key.has and { key.has } or nil
                local supported = not methods
                for _, m in ipairs(methods or {}) do
                  if not m:find("/", 1, true) then
                    m = "textDocument/" .. m
                  end
                  if client:supports_method(m, buf) then
                    supported = true
                    break
                  end
                end
                local enabled = key.enabled
                if type(enabled) == "function" then
                  enabled = enabled(buf)
                end
                if supported and enabled ~= false then
                  vim.keymap.set(key.mode or "n", key[1], key[2], {
                    buffer = buf,
                    silent = true,
                    nowait = key.nowait,
                    desc = key.desc,
                  })
                end
              end
            end
          end

          -- inlay hints
          if
            opts.inlay_hints.enabled
            and client:supports_method("textDocument/inlayHint", buf)
            and vim.bo[buf].buftype == ""
            and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buf].filetype)
          then
            vim.lsp.inlay_hint.enable(true, { bufnr = buf })
          end

          -- folds: window-local (o global "indent" do config/options.lua fica intacto;
          -- LazyVim.set_default retornaria false aqui e os folds LSP nunca ativariam)
          -- ponytail: split novo no mesmo buffer herda o global; mover p/ FileType se incomodar
          if opts.folds.enabled and client:supports_method("textDocument/foldingRange", buf) then
            for _, win in ipairs(vim.fn.win_findbuf(buf)) do
              vim.wo[win].foldmethod = "expr"
              vim.wo[win].foldexpr = "v:lua.vim.lsp.foldexpr()"
            end
          end

          -- codelens
          if opts.codelens.enabled and vim.lsp.codelens and client:supports_method("textDocument/codeLens", buf) then
            vim.lsp.codelens.enable(true)
            vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
              buffer = buf,
              callback = vim.lsp.codelens.enable(true),
            })
          end
        end,
      })

      -- diagnostics
      if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
        opts.diagnostics.virtual_text.prefix = function(diagnostic)
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
          return "●"
        end
      end
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- default config para todos os servers
      if opts.servers["*"] then
        vim.lsp.config("*", opts.servers["*"])
      end

      -- servers disponíveis via mason-lspconfig
      local mason_all = vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
      local mason_exclude = {}

      ---@return boolean? exclude automatic setup
      local function configure(server)
        if server == "*" then
          return false
        end
        local sopts = opts.servers[server]
        sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup["*"]
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts) -- configura o server
          if not use_mason then
            vim.lsp.enable(server)
          end
        end
        return use_mason
      end

      local install = vim.iter(names):filter(configure):totable()
      require("mason-lspconfig").setup({
        ensure_installed = install,
        automatic_enable = { exclude = mason_exclude },
      })
    end,
  },
  { "mason-org/mason-lspconfig.nvim", config = function() end },
  -- lazy.nvim
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = "cs",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
    config = function()
      require("easy-dotnet").setup()
    end,
  },
}
