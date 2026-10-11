-- =========================================================================
-- Toggle do code lens de referências do Roslyn
-- =========================================================================
-- O contador de referências acima dos símbolos polui diffs lado a lado.
-- Alterna via `<leader>uC` (família dos [U]i toggles) ou `:DotnetCodelens`.
--
-- Desligar de verdade exige os dois lados:
--   * `client.settings`: é daqui que o nvim responde o pull
--     `workspace/configuration` que o Roslyn faz ao receber o notify; sem
--     mutar aqui ele re-puxa a config antiga e as lens voltam no próximo
--     refresh (os autocmds de refresh do easy-dotnet continuam rodando);
--   * roundtrip em `vim.lsp.codelens`: enable(false) limpa o virtual text
--     renderizado na hora e enable(true) pede as lens de novo (vazias
--     quando off, cheias quando on).
local codelens_on = true -- default do Roslyn (o plugin não mexe nele)

---@param on boolean
local function apply_codelens(on)
  for _, client in ipairs(vim.lsp.get_clients({ name = "easy_dotnet" })) do
    local section = client.settings["csharp|code_lens"]
    if type(section) ~= "table" then
      section = {}
    end
    ---@cast section table
    client.settings["csharp|code_lens"] = vim.tbl_deep_extend("force", section, {
      dotnet_enable_references_code_lens = on,
    })
    client:notify("workspace/didChangeConfiguration", {
      settings = { ["csharp|code_lens"] = { dotnet_enable_references_code_lens = on } },
    })
    vim.lsp.codelens.enable(false, { client_id = client.id })
    vim.lsp.codelens.enable(true, { client_id = client.id })
  end
end

---Alterna o code lens de referências (todos os clients easy_dotnet).
local function toggle_codelens()
  codelens_on = not codelens_on
  apply_codelens(codelens_on)
  vim.notify("Code lens de referências: " .. (codelens_on and "ligado" or "desligado"))
end

vim.api.nvim_create_user_command("DotnetCodelens", toggle_codelens, {
  desc = "Alterna o code lens de referências do Roslyn (easy-dotnet)",
})

vim.keymap.set("n", "<leader>ld", "<cmd>Dotnet<cr>", { desc = "Dotnet: comandos" })
vim.keymap.set("n", "<leader>uC", "<cmd>DotnetCodelens<cr>", { desc = "[U]i Toggle [C]ode Lens (refs)" })
