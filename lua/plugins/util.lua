local function diff_branch()
  local cwd = vim.fn.getcwd()
  local current = vim.trim(vim.fn.system("git branch --show-current"))
  local branches = vim.fn.systemlist({
    "git",
    "for-each-ref",
    "--format=%(if)%(symref)%(then)%(else)%(refname:short)%(end)",
    "refs/heads",
    "refs/remotes",
  })
  if vim.v.shell_error ~= 0 then
    return vim.notify("Not in a git repository", vim.log.levels.WARN)
  end
  branches = vim.tbl_filter(function(b)
    return b ~= "" and b ~= current
  end, branches)
  vim.ui.select(branches, { prompt = "Diff branch: " .. (current ~= "" and current or "HEAD") }, function(branch)
    if not branch then
      return
    end
    vim.api.nvim_cmd({ cmd = "CodeDiff", args = { "--repo", cwd, "HEAD", branch } }, {})
  end)
end

return {
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- só começa a rastrear quando você abre um arquivo
    opts = {
      need = 1,           -- só salva se houver ao menos 1 buffer de arquivo
      -- branch = true, -- opcional: uma sessão por branch do git
    },
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Select Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
  {
    "figofigueiroa/rest.nvim",
    ft = { "http" },
    keys = {
      { "<leader>R",  "",                          desc = "+Rest" },
      { "<leader>Re", "<cmd>Rest env select<cr>",  desc = "Select environment",           ft = "http" },
      { "<leader>Ro", "<cmd>Rest open<cr>",        desc = "Open result pane",             ft = "http" },
      { "<leader>Rr", "<cmd>Rest run<cr>",         desc = "Send the request",             ft = "http" },
      { "<leader>RR", "<cmd>Rest last<cr>",        desc = "Replay the last request",      ft = "http" },
      { "<leader>Rv", "<cmd>Rest vars select<cr>", desc = "Select vars for http session", ft = "http" },
      { "<leader>Rl", "<cmd>Rest vars list<cr>",   desc = "List vars for http session",   ft = "http" },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "http")
        table.insert(opts.ensure_installed, "graphql")
      end,
    },
  },
  {
    "esmuellert/codediff.nvim",
    keys = {
      { "<leader>gD", diff_branch, desc = "Diff Branch (CodeDiff)" },
    },
    opts = { diff = { compute_moves = true }, }
  },
}
