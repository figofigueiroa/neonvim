local function del_qf_item()
  local items = vim.fn.getqflist()
  local line = vim.fn.line(".")

  table.remove(items, line)
  vim.fn.setqflist(items, "r")

  local new_line = math.min(line, #items)
  if new_line > 0 then
    vim.api.nvim_win_set_cursor(0, { new_line, 0 })
  end
end

vim.keymap.set("n", "dd", del_qf_item, {
  buffer = true,
  silent = true,
  desc = "Remove entry from QF",
})

vim.keymap.set("n", "D", del_qf_item, {
  buffer = true,
  silent = true,
  desc = "Remove entry from QF",
})
