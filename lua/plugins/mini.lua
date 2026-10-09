-- Monorepo mini.nvim: 1 plugin = 1 config. No lazy.nvim, fragments do mesmo repo
-- mesclam num plugin só (keys/event se unem; config de fragment anterior é
-- sombreado) — não splitar em vários fragments com config.
-- ponytail: defer por módulo além do mini.files exigiria placeholder keymaps;
-- o statusline define o piso (UIEnter) e os demais módulos são baratos.
return {
  "nvim-mini/mini.nvim",
  event = "UIEnter",
  config = function()
    require("mini.statusline").setup()
    require("mini.statuscolumn").setup()
    require("mini.ai").setup()
    require("mini.pairs").setup()
    require("mini.jump").setup()
    require("mini.surround").setup()
    -- ícones para statusline/mini.files (módulo do próprio monorepo)
    require("mini.icons").setup()
    require("mini.pick").setup()
  end,
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
  },
}
