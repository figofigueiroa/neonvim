-- This file is automatically loaded by lazyvim.config.init.
local U = require("config.utils")

local function augroup(name)
  return vim.api.nvim_create_augroup("figo_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    if vim.fn.has("nvim-0.13") == 1 then
      vim.hl.hl_op()
    else
      (vim.hl or vim.highlight).on_yank()
    end
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dap-float",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("autoformat"),
  callback = function(event)
    if vim.g.autoformat == false or vim.b[event.buf].autoformat == false then
      return
    end
    vim.lsp.buf.format({ bufnr = event.buf, async = false })
  end,
})

-- Grupos de keyword do treesitter + grupos legados (syntax regex)
local keyword_groups = {
  "@keyword",
  "@keyword.coroutine",
  "@keyword.function",
  "@keyword.operator",
  "@keyword.import",
  "@keyword.type",
  "@keyword.modifier",
  "@keyword.repeat",
  "@keyword.return",
  "@keyword.debug",
  "@keyword.exception",
  "@keyword.conditional",
  "@keyword.conditional.ternary",
  "@keyword.directive",
  "@keyword.directive.define",
  "Keyword",
  "Statement",
  "Conditional",
  "Repeat",
  "Exception",
  "Include",
}

-- Definição efetiva do grupo, subindo na hierarquia se não existir
-- (@keyword.return -> @keyword), como o fallback do treesitter faz
local function resolve_hl(name)
  while name do
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
    if next(hl) then
      return hl
    end
    name = name:match("^(.*)%.[^.]+$")
  end
  return {}
end

-- nvim_set_hl SUBSTITUI o grupo inteiro; isto mescla só o que você passar
local function extend_hl(name, attrs)
  local hl = vim.tbl_deep_extend("force", resolve_hl(name), attrs)
  ---@cast hl vim.api.keyset.highlight
  vim.api.nvim_set_hl(0, name, hl)
end

-- Keywords de linguagens em negrito, preservando o fg (gui e cterm)
local function bold_keywords()
  for _, group in ipairs(keyword_groups) do
    extend_hl(group, { bold = true, cterm = { bold = true } })
  end
end

-- Modo debug (debugmaster): badge vermelho "DEBUG" na statusline;
-- cores fixas, vale para qualquer tema
local function debug_mode_hl()
  vim.api.nvim_set_hl(0, "MiniStatuslineModeDebug", { bg = "#FF2c2c", fg = "#1e1e1e", ctermbg = 30, bold = true })
end

local function habamax_overrides()
  local set = vim.api.nvim_set_hl
  -- Fundo transparente, preservando o fg do habamax
  extend_hl("Normal", { bg = "NONE", ctermbg = "NONE" })
  set(0, "NormalFloat", { link = "Normal" })
  set(0, "FloatBorder", { fg = "#767676", bg = "NONE" })
  set(0, "VertSplit", { fg = "#767676", bg = "NONE" })

  set(0, "TabLineSel", { link = "PmenuSel" })
  set(0, "TabLine", { link = "StatusLineNC" })
  set(0, "TabLineFill", { link = "StatusLineNC" })

  -- Diffs (vimdiff nativo, codediff, neogit) ficam em colors/habamax-diff.lua,
  -- camada aplicada depois destes overrides
  set(0, "String", { fg = "#9ed99c" }) -- também alimenta o verde do neogit
  set(0, "@string", { link = "String" }) -- Treesitter strings

  debug_mode_hl()

  -- Keywords em negrito (gui e cterm)
  bold_keywords()
end

-- Alabaster: keywords em negrito + badge de modo debug na statusline
local function alabaster_overrides()
  bold_keywords()
  debug_mode_hl()
end

if vim.g.colors_name == "habamax" then
  habamax_overrides()
end

if vim.g.colors_name == "alabaster" then
  alabaster_overrides()
end

vim.api.nvim_create_autocmd("ColorScheme", {
  -- "habamax-diff" (colors/habamax-diff.lua) carrega este tema como base
  pattern = { "habamax", "habamax-diff" },
  group = augroup("habamax_overrides"),
  callback = habamax_overrides,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "alabaster",
  group = augroup("alabaster_overrides"),
  callback = alabaster_overrides,
})

local Event = require("lazy.core.handler.event")

local events = { "BufReadPost", "BufNewFile", "BufWritePre" }

Event.mappings.LazyFile = { id = "LazyFile", event = "User", pattern = "LazyFile" }
Event.mappings["User LazyFile"] = Event.mappings.LazyFile

local group = augroup("lazy_file")

vim.api.nvim_create_autocmd(events, {
  group = group,
  once = true,
  callback = function(ev)
    -- stop this autocmd, then let lazy load the plugins
    vim.api.nvim_del_augroup_by_id(group)

    -- fire the user event once the UI is ready
    vim.schedule(function()
      vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
      -- replay the original event so freshly loaded plugins see it
      vim.api.nvim_exec_autocmds(ev.event, { buffer = ev.buf, modeline = false })
    end)
  end,
})

local debug_mode = U.debug_mode

vim.api.nvim_create_autocmd("User", {
  pattern = "DebugModeChanged",
  callback = function(args)
    debug_mode.set(args.data.enabled)
    vim.cmd("redrawstatus")
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
  group = augroup("MarkSigns"),
  callback = function(ev)
    U.refresh_marks(ev.buf)
  end,
  desc = "Show marks in statuscolumn",
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = group,
  pattern = ":",
  callback = function()
    if vim.fn.getcmdline():match("^%s*delm") then
      -- CmdlineLeave roda ANTES do comando executar, então adia o refresh
      vim.schedule(function()
        U.refresh_marks()
      end)
    end
  end,
  desc = "Update mark signs after :delmarks",
})

-- vim.api.nvim_create_autocmd("BufReadPost", {
--   callback = function(ev)
--     local root = vim.fs.root(ev.buf, { ".git", "Makefile" })
--     if root then
--       vim.cmd.bcd(root)
--     end
--   end,
-- })
--
------------------------------------------------
--
-- Quickfix
--
------------------------------------------------

-- Remove items from quickfix list.
-- `dd` to delete in Normal
-- `d` to delete Visual selection
local function delete_qf_items()
  local mode = vim.api.nvim_get_mode()["mode"]

  local start_idx
  local count

  if mode == "n" then
    -- Normal mode
    start_idx = vim.fn.line(".")
    count = vim.v.count > 0 and vim.v.count or 1
  else
    -- Visual mode
    local v_start_idx = vim.fn.line("v")
    local v_end_idx = vim.fn.line(".")

    start_idx = math.min(v_start_idx, v_end_idx)
    count = math.abs(v_end_idx - v_start_idx) + 1

    -- Go back to normal
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes(
        "<esc>", -- what to escape
        true, -- Vim leftovers
        false, -- Also replace `<lt>`?
        true -- Replace keycodes (like `<esc>`)?
      ),
      "x", -- Mode flag
      false -- Should be false, since we already `nvim_replace_termcodes()`
    )
  end

  local qflist = vim.fn.getqflist()

  for _ = 1, count, 1 do
    table.remove(qflist, start_idx)
  end

  vim.fn.setqflist(qflist, "r")
  vim.fn.cursor(start_idx, 1)
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("quickfix_tweaks"),
  pattern = "qf",
  callback = function()
    -- Do not show quickfix in buffer lists.

    vim.api.nvim_set_option_value("buflisted", false, { buf = 0 })

    -- Escape closes quickfix window.
    vim.keymap.set("n", "<ESC>", "<CMD>cclose<CR>", { buffer = true, remap = false, silent = true })

    -- `dd` deletes an item from the list.
    vim.keymap.set("n", "dd", delete_qf_items, { buffer = true })
    vim.keymap.set("x", "d", delete_qf_items, { buffer = true })
  end,
  desc = "Quickfix tweaks",
})
