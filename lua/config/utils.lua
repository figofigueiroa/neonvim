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

return M
