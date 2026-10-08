-- This file is automatically loaded by lazyvim.config.init.

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
    vim.opt_local.spell = true
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

local function habamax_overrides()
  -- Fundo transparente, preservando o fg do habamax
  extend_hl("Normal", { bg = "NONE", ctermbg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#767676", bg = "NONE" })
  vim.api.nvim_set_hl(0, "VertSplit", { fg = "#767676", bg = "NONE" })

  vim.api.nvim_set_hl(0, "TabLineSel", { link = "PmenuSel" })
  vim.api.nvim_set_hl(0, "TabLine", { link = "StatusLineNC" })
  vim.api.nvim_set_hl(0, "TabLineFill", { link = "StatusLineNC" })

  -- Diffs mais legíveis que os do habamax (#274733/#373737/#2f1f1a); o neogit
  -- deriva os fundos dos diffs dele (line_green/line_red) do bg de
  -- DiffAdd/DiffDelete, e o codediff linka direto nesses grupos.
  vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#2e5c46", ctermbg = 22 })
  vim.api.nvim_set_hl(0, "DiffChange", { bg = "#39434f", ctermbg = 238 })
  vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#462626", fg = "#d78787", ctermbg = 52, ctermfg = 138 })
  vim.api.nvim_set_hl(0, "DiffText", { bg = "#1c6a75", ctermbg = 30 })

  -- Keywords em negrito (gui e cterm)
  for _, group in ipairs(keyword_groups) do
    extend_hl(group, { bold = true, cterm = { bold = true } })
  end
end

if vim.g.colors_name == "habamax" then
  habamax_overrides()
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "habamax",
  group = augroup("habamax_overrides"),
  callback = habamax_overrides,
})
