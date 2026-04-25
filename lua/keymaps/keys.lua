local map = vim.keymap.set

local function root()
  return vim.fs.root(0, {
    ".git",
    "package.json",
    "pyproject.toml",
    "slnx",
    "*.sln",
    "*.csproj",
  }) or vim.uv.cwd()
end

local function snacks()
  local ok, Snacks = pcall(require, "snacks")
  if ok then
    return Snacks
  end
  vim.notify("snacks.nvim is not available", vim.log.levels.WARN)
end

local function floating_terminal(cmd, title, cwd)
  local Snacks = snacks()
  if not Snacks then
    return
  end

  Snacks.terminal.open(cmd, {
    cwd = cwd or root(),
    border = "rounded",
    title = title,
    title_pos = "center",
  })
end

local function lazygit(cwd)
  local Snacks = snacks()
  if not Snacks then
    return
  end

  Snacks.lazygit({ cwd = cwd or root() })
end


-- Editing
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save File" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear Search" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half Page Down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half Page Up" })
map("n", "n", "nzzzv", { desc = "Next Search Result" })
map("n", "N", "Nzzzv", { desc = "Previous Search Result" })
map("v", "<", "<gv", { desc = "Indent Left" })
map("v", ">", ">gv", { desc = "Indent Right" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })
map("n", "<leader>ww", "<C-w>p", { desc = "Other Window" })
map("n", "<leader>wh", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Go to Lower Window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Go to Upper Window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Go to Right Window" })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete Window" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split Window Below" })
map("n", "<leader>|", "<C-w>v", { desc = "Split Window Right" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize Windows" })

-- Tabs
pcall(vim.keymap.del, "n", "<leader><tab>[")
pcall(vim.keymap.del, "n", "<leader><tab>]")
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab>g", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>l", "<cmd>tabnext<cr>", { desc = "Next Tab" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function()
  local Snacks = snacks()
  if Snacks and Snacks.bufdelete then
    Snacks.bufdelete()
  else
    vim.cmd("bdelete")
  end
end, { desc = "Delete Buffer" })
map("n", "<leader>bD", function()
  local Snacks = snacks()
  if Snacks and Snacks.bufdelete then
    Snacks.bufdelete({ force = true })
  else
    vim.cmd("bdelete!")
  end
end, { desc = "Delete Buffer Force" })
map("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.bo[buf].buflisted then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end, { desc = "Delete Other Buffers" })

-- Files, search, and pickers
map("n", "<leader><leader>", function()
  require("snacks.picker").files()
end, { desc = "Find Files" })
map("n", "<leader><space>", function()
  require("snacks.picker").files()
end, { desc = "Find Files" })
map("n", "<leader>,", function()
  require("snacks.picker").buffers()
end, { desc = "Buffers" })
map("n", "<leader>/", function()
  require("snacks.picker").grep()
end, { desc = "Grep" })
map("n", "<leader>:", function()
  require("snacks.picker").command_history()
end, { desc = "Command History" })
map("n", "<leader>fr", function()
  require("snacks.picker").recent()
end, { desc = "Recent Files" })
map("n", "<leader>e", function()
  require("snacks").explorer({ cwd = root() })
end, { desc = "Explorer" })
map("n", "<leader>E", function()
  require("snacks").explorer({ cwd = vim.fn.getcwd() })
end, { desc = "Explorer (cwd)" })
map("n", "<leader>ff", function()
  require("snacks.picker").files()
end, { desc = "Find Files" })
map("n", "<leader>fg", function()
  require("snacks.picker").git_files()
end, { desc = "Find Git Files" })
map("n", "<leader>sg", function()
  require("snacks.picker").grep()
end, { desc = "Grep" })
map("n", "<leader>sw", function()
  require("snacks.picker").grep_word()
end, { desc = "Grep Word" })

-- Git
map("n", "<leader>gg", function()
  lazygit()
end, { desc = "Lazygit" })
map("n", "<leader>gG", function()
  lazygit(vim.fn.getcwd())
end, { desc = "Lazygit (cwd)" })
map("n", "<leader>gb", function()
  require("gitsigns").blame_line({ full = true })
end, { desc = "Git Blame Line" })

-- Terminals and tools
vim.keymap.set("n", "<leader>qq", "<cmd>confirm qa<cr>", {
  desc = "Quit All",
})
map("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Enter Normal Mode" })
map({ "n", "t" }, "<C-/>", function()
  floating_terminal(nil, "Terminal")
end, { desc = "Terminal" })
map({ "n", "t" }, "<C-_>", function()
  floating_terminal(nil, "Terminal")
end, { desc = "Terminal" })
map("n", "<leader>ft", function()
  floating_terminal(nil, "Terminal")
end, { desc = "Terminal" })
map("n", "<leader>cD", function()
  floating_terminal({ "lazysql" }, "Lazysql")
end, { desc = "Lazysql" })
map("n", "<leader>ch", function()
  floating_terminal({ "chronos" }, "Chronos")
end, { desc = "Chronos" })
map("n", "<leader>z", function()
  require("snacks").zen()
end, { desc = "Toggle Zen" })

-- CodeCompanion
map("n", "<leader>co", function()
  require("codecompanion").toggle_chat()
end, { desc = "AI Helper" })
map("n", "<leader>cO", function()
  require("codecompanion").chat()
end, { desc = "AI Helper (new chat)" })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "codecompanion",
  callback = function(args)
    map("n", "<C-c>", function()
      require("codecompanion").toggle_chat()
    end, { buffer = args.buf, silent = true, desc = "Hide Chat" })
  end,
})

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next Diagnostic" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous Diagnostic" })
map("n", "]e", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Next Error" })
map("n", "[e", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Previous Error" })
map("n", "]w", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.WARN, float = true })
end, { desc = "Next Warning" })
map("n", "[w", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.WARN, float = true })
end, { desc = "Previous Warning" })

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    local lspmap = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
    end

    lspmap("gd", vim.lsp.buf.definition, "Goto Definition")
    lspmap("gD", vim.lsp.buf.declaration, "Goto Declaration")
    lspmap("gr", vim.lsp.buf.references, "References")
    lspmap("gI", vim.lsp.buf.implementation, "Goto Implementation")
    lspmap("gy", vim.lsp.buf.type_definition, "Goto Type Definition")
    lspmap("K", vim.lsp.buf.hover, "Hover")
    lspmap("<leader>cr", vim.lsp.buf.rename, "Rename")
    lspmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
  end,
})

