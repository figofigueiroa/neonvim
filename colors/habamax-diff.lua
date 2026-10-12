-- habamax-diff: habamax + diffs legíveis (vimdiff nativo, codediff.nvim, neogit)
-- Uso: :colorscheme habamax-diff
--
-- :colorscheme aninhado é no-op silencioso neste build (habamax nem
-- carregava); source direto no lugar. O evento ColorScheme que segue aplica
-- os overrides do config/autocmds.lua (fundo transparente, String, keywords
-- em negrito — autocmd pattern "habamax-diff"). Esta camada cobre só diff:
--   - vimdiff nativo: Diff* com fundo visível e fg herdado do Normal (o
--     DiffDelete do habamax é fg #767676 sobre bg #2f1f1a — quase invisível)
--   - filetype diff (patches, commits): diffAdded/diffRemoved linkam em
--     Added/Changed/Removed
--   - codediff.nvim deriva CodeDiffLine*/Char* de DiffAdd/DiffDelete
--   - neogit deriva o fundo das linhas (line_red/line_green) de
--     DiffDelete/DiffAdd; o fg das deletadas é fixado em plugins/editor.lua
-- ponytail: hexes calibrados p/ terminal escuro com Normal transparente;
-- para background=light, recalibrar os bg abaixo
vim.cmd.source(vim.env.VIMRUNTIME .. "/colors/habamax.vim")

local set = vim.api.nvim_set_hl

set(0, "DiffAdd", { bg = "#2a5040", ctermbg = 22 })
set(0, "DiffChange", { bg = "#40485a", ctermbg = 238 })
set(0, "DiffDelete", { bg = "#522a35", ctermbg = 52 })
set(0, "DiffText", { bg = "#186a6a", bold = true, ctermbg = 30, cterm = { bold = true } })

set(0, "Added", { fg = "#9ed99c", ctermfg = 114 })
set(0, "Changed", { fg = "#d9b96a", ctermfg = 179 })
set(0, "Removed", { fg = "#e08a8a", ctermfg = 174 })

vim.g.colors_name = "habamax-diff"
