local M = {}

function M.is_win()
  return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

---@param name string
function M.get_plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has(plugin)
  return M.get_plugin(plugin) ~= nil
end

---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

M.icons = {
  misc = {
    dots = "󰇘",
  },
  ft = {
    octo = " ",
    gh = " ",
    ["markdown.gh"] = " ",
  },
  dap = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = " ",
    BreakpointCondition = " ",
    BreakpointRejected = { " ", "DiagnosticError" },
    LogPoint = ".>",
  },
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
  kinds = {
    Array = " ",
    Boolean = "󰨙 ",
    Class = " ",
    Codeium = "󰘦 ",
    Color = " ",
    Control = " ",
    Collapsed = " ",
    Constant = "󰏿 ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = "󰊕 ",
    Module = " ",
    Namespace = "󰦮 ",
    Null = " ",
    Number = "󰎠 ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = "󱄽 ",
    String = " ",
    Struct = "󰆼 ",
    Supermaven = " ",
    TabNine = "󰏚 ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = "󰀫 ",
  },
}
-- Estado compartilhado do debug mode
M.debug_mode = {
  enabled = false,
}

function M.debug_mode.get()
  return M.debug_mode.enabled
end

function M.debug_mode.set(value)
  M.debug_mode.enabled = value and true or false
end

M._installed = nil ---@type table<string,boolean>?
M._queries = {} ---@type table<string,boolean>

---@param update boolean?
function M.get_installed(update)
  if update then
    M._installed, M._queries = {}, {}
    for _, lang in ipairs(require("nvim-treesitter").get_installed("parsers")) do
      M._installed[lang] = true
    end
  end
  return M._installed or {}
end

---@param lang string
---@param query string
function M.have_query(lang, query)
  local key = lang .. ":" .. query
  if M._queries[key] == nil then
    M._queries[key] = vim.treesitter.query.get(lang, query) ~= nil
  end
  return M._queries[key]
end

---@param what string|number|nil
---@param query? string
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
function M.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == "number" and vim.bo[what].filetype or what --[[@as string]]
  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then
    return false
  end
  if query and not M.have_query(lang, query) then
    return false
  end
  return true
end

function M.foldexpr()
  return M.have(nil, "folds") and vim.treesitter.foldexpr() or "0"
end

function M.indentexpr()
  return M.have(nil, "indents") and require("nvim-treesitter").indentexpr() or -1
end

---@return string?
local function win_find_cl()
  local path = "C:/Program Files (x86)/Microsoft Visual Studio"
  local pattern = "*/*/VC/Tools/MSVC/*/bin/Hostx64/x64/cl.exe"
  return vim.fn.globpath(path, pattern, true, true)[1]
end

---@return boolean ok, Health health
function M.check()
  local is_win = vim.fn.has("win32") == 1
  ---@param tool string
  ---@param win boolean?
  local function have(tool, win)
    return (win == nil or is_win == win) and vim.fn.executable(tool) == 1
  end

  local have_cc = vim.env.CC ~= nil or have("cc", false) or have("cl", true) or (is_win and win_find_cl() ~= nil)

  if not have_cc and is_win and vim.fn.executable("gcc") == 1 then
    vim.env.CC = "gcc"
    have_cc = true
  end

  ---@class Health: table<string,boolean>
  local ret = {
    ["tree-sitter (CLI)"] = have("tree-sitter"),
    ["C compiler"] = have_cc,
    tar = have("tar"),
    curl = have("curl"),
  }
  local ok = true
  for _, v in pairs(ret) do
    ok = ok and v
  end
  return ok, ret
end

---@param cb fun()
function M.build(cb)
  M.ensure_treesitter_cli(function(_, err)
    local ok, health = M.check()
    if ok then
      return cb()
    else
      local lines = { "Unmet requirements for **nvim-treesitter** `main`:" }
      local keys = vim.tbl_keys(health) ---@type string[]
      table.sort(keys)
      for _, k in pairs(keys) do
        lines[#lines + 1] = ("- %s `%s`"):format(health[k] and "✅" or "❌", k)
      end
      vim.list_extend(lines, {
        "",
        "See the requirements at [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/tree/main?tab=readme-ov-file#requirements)",
        "Run `:checkhealth nvim-treesitter` for more information.",
      })
      if vim.fn.has("win32") == 1 and not health["C compiler"] then
        lines[#lines + 1] = "Install a C compiler with `winget install --id=BrechtSanders.WinLibs.POSIX.UCRT -e`"
      end
      vim.list_extend(lines, err and { "", err } or {})
      vim.notify(table.concat(lines, "\n"), vim.log.levels.ERROR, { title = "Treesitter" }) -- Update this line
    end
  end)
end

---@param cb fun(ok:boolean, err?:string)
function M.ensure_treesitter_cli(cb)
  if vim.fn.executable("tree-sitter") == 1 then
    return cb(true)
  end

  -- try installing with mason
  if not pcall(require, "mason") then
    return cb(false, "`mason.nvim` is disabled in your config, so we cannot install it automatically.")
  end

  -- check again since we might have installed it already
  if vim.fn.executable("tree-sitter") == 1 then
    return cb(true)
  end

  local mr = require("mason-registry")
  mr.refresh(function()
    local p = mr.get_package("tree-sitter-cli")
    if not p:is_installed() then
      vim.notify("Installing `tree-sitter-cli` with `mason.nvim`...", vim.log.levels.INFO) -- Update this line
      p:install(
        nil,
        vim.schedule_wrap(function(success)
          if success then
            vim.notify("Installed `tree-sitter-cli` with `mason.nvim`.", vim.log.levels.INFO) -- Update this line
            cb(true)
          else
            cb(false, "Failed to install `tree-sitter-cli` with `mason.nvim`.")
          end
        end)
      )
    end
  end)
end

function M.ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line("$")
  if ai_type == "i" then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

function M.is_loaded(name)
  local Config = require("lazy.core.config")
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

M.mini = {}

-- textobject "g": buffer inteiro ("ig" ignora linhas em branco nas pontas)
function M.mini.ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line("$")
  if ai_type == "i" then
    local first, last = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    if first == 0 or last == 0 then -- buffer só com linhas vazias
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first, last
  end
  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

-- registra descrições dos textobjects no which-key
function M.mini.ai_whichkey(opts)
  local objects = {
    { " ", desc = "whitespace" },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { "(", desc = "() block" },
    { ")", desc = "() block with ws" },
    { "<", desc = "<> block" },
    { ">", desc = "<> block with ws" },
    { "?", desc = "user prompt" },
    { "U", desc = "use/call without dot" },
    { "[", desc = "[] block" },
    { "]", desc = "[] block with ws" },
    { "_", desc = "underscore" },
    { "`", desc = "` string" },
    { "a", desc = "argument" },
    { "b", desc = ")]} block" },
    { "c", desc = "class" },
    { "d", desc = "digit(s)" },
    { "e", desc = "CamelCase / snake_case" },
    { "f", desc = "function" },
    { "g", desc = "entire file" },
    { "i", desc = "indent" },
    { "o", desc = "block, conditional, loop" },
    { "q", desc = "quote `\"'" },
    { "t", desc = "tag" },
    { "u", desc = "use/call" },
    { "{", desc = "{} block" },
    { "}", desc = "{} with ws" },
  }

  local ret = { mode = { "o", "x" } }
  local mappings = vim.tbl_extend("force", {
    around = "a",
    inside = "i",
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",
  }, opts.mappings or {})
  mappings.goto_left, mappings.goto_right = nil, nil

  for name, prefix in pairs(mappings) do
    name = name:gsub("^around_", ""):gsub("^inside_", "")
    ret[#ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      if prefix:sub(1, 1) == "i" then
        desc = desc:gsub(" with ws", "")
      end
      ret[#ret + 1] = { prefix .. obj[1], desc = desc }
    end
  end
  require("which-key").add(ret, { notify = false })
end

---@param what string|number|nil
---@param query? string
---@overload fun(buf?:number):boolean
---@overload fun(ft:string):boolean
---@return boolean
function M.have(what, query)
  what = what or vim.api.nvim_get_current_buf()
  what = type(what) == "number" and vim.bo[what].filetype or what --[[@as string]]
  local lang = vim.treesitter.language.get_lang(what)
  if lang == nil or M.get_installed()[lang] == nil then
    return false
  end
  if query and not M.have_query(lang, query) then
    return false
  end
  return true
end

M.actions = {
  -- Native Snippets
  snippet_forward = function()
    if vim.snippet.active({ direction = 1 }) then
      vim.schedule(function()
        vim.snippet.jump(1)
      end)
      return true
    end
  end,
  snippet_stop = function()
    if vim.snippet then
      vim.snippet.stop()
    end
  end,
}

---@param actions string[]
---@param fallback? string|fun()
function M.map(actions, fallback)
  return function()
    for _, name in ipairs(actions) do
      if M.actions[name] then
        local ret = M.actions[name]()
        if ret then
          return true
        end
      end
    end
    return type(fallback) == "function" and fallback() or fallback
  end
end

local mark_ns = vim.api.nvim_create_namespace("mark_signs")

M.refresh_marks = function(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, mark_ns, 0, -1)
  local n_lines = vim.api.nvim_buf_line_count(buf)

  local function place(name, lnum)
    if lnum < 1 or lnum > n_lines then
      return
    end
    vim.api.nvim_buf_set_extmark(buf, mark_ns, lnum - 1, 0, {
      sign_text = name,
      sign_hl_group = "DiagnosticHint",
      priority = 5,
    })
  end

  for _, m in ipairs(vim.fn.getmarklist(buf)) do
    local name = m.mark:sub(2)
    if name:match("^%l$") then
      place(name, m.pos[2])
    end
  end

  for _, m in ipairs(vim.fn.getmarklist()) do
    local name = m.mark:sub(2)
    if name:match("^%u$") and m.pos[1] == buf then
      place(name, m.pos[2])
    end
  end
end
-- Retorna as letras das marks na linha atual (ex.: { 'a', 'C' })
M.marks_on_line = function(buf, lnum)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  lnum = lnum or vim.api.nvim_win_get_cursor(0)[1]
  local res = {}

  for _, m in ipairs(vim.fn.getmarklist(buf)) do
    local name = m.mark:sub(2)
    if name:match("^%l$") and m.pos[2] == lnum then
      table.insert(res, name)
    end
  end

  for _, m in ipairs(vim.fn.getmarklist()) do
    local name = m.mark:sub(2)
    if name:match("^%u$") and m.pos[1] == buf and m.pos[2] == lnum then
      table.insert(res, name)
    end
  end

  return res
end

return M
