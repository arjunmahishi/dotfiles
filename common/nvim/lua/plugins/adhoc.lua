local function create_telescope_picker(items, callback)
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local conf = require('telescope.config').values

  local selected_item = nil

  local function on_select(selection)
    selected_item = selection[1]
  end

  pickers.new({}, {
    prompt_title = "Select remote",
    finder = finders.new_table {
      results = items,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<CR>', function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        on_select(selection)
      end)
      return true
    end,
  }):find()

  if callback then
    callback(selected_item)
  end
end

local function open_in_github(start_line, end_line)
  local remote = ""
  local remotes = vim.fn.systemlist("git remote")
  if #remotes > 1 then
    local co = coroutine.running()
    create_telescope_picker(remotes, function(r)
      remote = r
      -- Resume the coroutine after selection
      coroutine.resume(co)
    end)
    -- Pause execution here until resumed by the callback
    coroutine.yield()
  else
    remote = remotes[1]
  end

  local handle = io.popen(string.format("git config --get remote.%s.url", remote))
  local repo_url = ""
  if handle then
    repo_url = handle:read("*a"):gsub("\n", "")
    handle:close()
  else
    print("Error: Unable to open git configuration.")
    return nil
  end

  local origin = "main" -- Set your default branch or origin here

  repo_url = repo_url:gsub("git@github.com:", "https://github.com/"):gsub("%.git$", "")

  local file_path = vim.fn.expand("%:p")
  print(file_path)
  local relative_path = vim.fn.fnamemodify(file_path, ":~:.")

  if repo_url ~= "" and relative_path ~= "" then
    local range = ""
    if start_line ~= end_line then
      range = string.format("#L%d-L%d", start_line, end_line)
    end

    local url = string.format("%s/blob/%s/%s%s", repo_url, origin, relative_path, range)
    vim.fn.setreg("+", url)

    -- Open URL in default browser
    -- os.execute(string.format("open '%s'", url))
    print(string.format("URL copied to clipboard: %s", url))
  else
    print("Error: Unable to determine repository URL or file path.")
    return nil
  end
end

vim.api.nvim_create_user_command('OpenSelectedInGithub', function(opts)
  open_in_github(opts.line1, opts.line2)
end, { nargs = '*', range = true })

vim.api.nvim_create_user_command('OpenFileInGithub', function(_)
  open_in_github()
end, { nargs = '*', range = true })

-- vim.api.nvim_set_keymap("v", "<leader>gh", '', { callback = open_in_github })
vim.keymap.set('v', '<leader>gh', ':OpenSelectedInGithub<CR>')
vim.keymap.set('n', '<leader>gh', ':OpenSelectedInGithub<CR>')

-- vim.api.nvim_set_keymap('n', '<leader>cf', [[:lua vim.fn.setreg('+', vim.fn.expand('%:p') .. ':' .. vim.fn.line('.'))<CR>:echo "Copied filename and line number"<CR>]], { noremap = true, silent = true })
vim.keymap.set('n', '<leader>cf',
  ':lua vim.fn.setreg("+", vim.fn.expand("%:p") .. ":" .. vim.fn.line("."))<CR>:echo "Copied filename and line number"<CR>')

return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        -- current_line_blame = true,
      })
    end,
  },
  {
    "jbyuki/venn.nvim",
    config = function()
      vim.api.nvim_set_keymap("v", "<leader>b", ":VBox<CR>", { noremap = true })
    end,
  },
  { "tpope/vim-fugitive" },
  { "ruanyl/vim-gh-line" },
}
