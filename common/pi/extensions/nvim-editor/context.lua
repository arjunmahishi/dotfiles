local draft = vim.api.nvim_get_current_buf()
local draft_window = vim.api.nvim_get_current_win()
local editor_height = vim.api.nvim_win_get_height(draft_window)
local lines = vim.fn.readfile(vim.env.PI_NVIM_RESPONSE)

-- Keep reference text out of every file-backed buffer.
vim.cmd("aboveleft new")
local reference = vim.api.nvim_get_current_buf()
local reference_window = vim.api.nvim_get_current_win()
vim.bo.buftype = "nofile"
vim.bo.bufhidden = "wipe"
vim.bo.swapfile = false
vim.bo.modeline = false
vim.api.nvim_buf_set_name(reference, "Agent response (scratch)")
vim.api.nvim_buf_set_lines(reference, 0, -1, false, lines)
vim.bo.filetype = "markdown"
vim.bo.modified = false
vim.bo.readonly = false
vim.bo.modifiable = true
vim.wo.wrap = true
vim.api.nvim_win_set_height(reference_window, math.max(1, math.min(#lines + 1, math.floor(editor_height / 2))))
vim.api.nvim_set_current_win(draft_window)

-- :wq / :q on the draft should not leave just the reference split open.
vim.api.nvim_create_autocmd("QuitPre", {
  buffer = draft,
  callback = function()
    if vim.api.nvim_win_is_valid(reference_window) then
      vim.api.nvim_win_close(reference_window, true)
    end
  end,
})
