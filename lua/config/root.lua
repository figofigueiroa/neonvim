-- Porte minimal do LazyVim.root: percorre vim.g.root_spec (options.lua)
-- "lsp"   -> root_dir do primeiro cliente LSP anexado ao buffer
-- table   -> dir ancestral mais próximo contendo um dos marcadores (ex: { ".git", "lua" })
-- "cwd"   -> diretório de trabalho
-- ponytail: sem cache (uso interativo, walk barato) e sem lista de LSPs ignorados
local M = {}

local function detect(spec, buf)
  if spec == "lsp" then
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      if client.root_dir then
        return client.root_dir
      end
    end
  elseif spec == "cwd" then
    return vim.uv.cwd()
  elseif type(spec) == "table" then
    local path = vim.api.nvim_buf_get_name(buf)
    if path ~= "" then
      return vim.fs.root(path, spec)
    end
  end
end

---@param buf number?
---@return string?
function M.get(buf)
  buf = buf or 0
  for _, spec in ipairs(vim.g.root_spec or { "lsp", { ".git", "lua" }, "cwd" }) do
    local root = detect(spec, buf)
    if root then
      return root
    end
  end
end

---@param buf number?
---@return string? root do repo git (nil fora de um repo)
function M.git(buf)
  buf = buf or 0
  local path = vim.api.nvim_buf_get_name(buf)
  if path ~= "" then
    return vim.fs.root(path, ".git")
  end
  return vim.fs.root(vim.uv.cwd(), ".git")
end

return M
