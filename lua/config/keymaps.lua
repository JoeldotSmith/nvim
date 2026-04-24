-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

vim.keymap.del("n", "<leader><tab>[")
vim.keymap.del("n", "<leader><tab>]")
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>")

function CloseTerminals()
  vim.api.nvim_command("bufdo if (bufname() =~ '^term://.*') | bd! | endif")
end

vim.api.nvim_create_user_command("KillTerminals", CloseTerminals, { desc = "Close all terminal buffers" })

vim.api.nvim_create_user_command("RunProject", function(opts)
  local ami = opts.args

  vim.cmd("tabnew")

  vim.cmd("terminal cd $(ls -d */ | grep -iE '^enco.*backend' | grep -ivE 'mini') && dotnet watch")
  vim.cmd("vsplit")

  if ami == "ami" then
    vim.cmd("terminal ./msql_connect.sh")
    vim.cmd("split")
  end

  vim.cmd("terminal cd $(ls -d */ | grep -iE '^enco.*frontend' | grep -ivE 'mini') && npm run dev")
end, { nargs = "?" })

vim.api.nvim_create_user_command("AmiMigration", function(opts)
  local migrationName = opts.args
  if migrationName == "" then
    print("Migration name is required")
    return
  end

  vim.cmd("vsplit")
  vim.cmd(
    "terminal "
      .. "/usr/local/share/dotnet/dotnet ef migrations add "
      .. "--project Enco.AMI.RS.Data/Enco.AMI.RS.Data.csproj "
      .. "--startup-project Enco.AMI.RS.FMG.Backend/Enco.AMI.RS.FMG.Backend.csproj "
      .. "--context Enco.AMI.RS.Data.AppDbContext "
      .. "--configuration Debug "
      .. migrationName
      .. " --output-dir Migrations"
  )
end, { nargs = 1 })

vim.api.nvim_create_user_command("Note", function()
  local notes_dir = vim.fn.expand("~/Notes")
  local filename = os.date("%Y-%m-%d") .. ".md"
  local path = notes_dir .. "/" .. filename

  if vim.fn.isdirectory(notes_dir) == 0 then
    vim.fn.mkdir(notes_dir, "p")
  end

  vim.cmd("tablast")
  vim.cmd("tabnew")
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end, {})

local Snacks = require("snacks")

vim.keymap.set("n", "<leader>z", function()
  Snacks.zen()
end, { silent = true, noremap = true })
vim.keymap.set("n", "<leader>Z", function()
  Snacks.zen.zoom()
end, { silent = true, noremap = true })
map("n", "<leader>cd", function()
  Snacks.terminal.open({ "lazysql" }, {
    cwd = require("lazyvim.util").root.get(),
    border = "rounded",
    title = "Lazysql",
    title_pos = "center",
  })
end, { desc = "Lazysql" })

map("n", "<leader>co", function()
  require("codecompanion").toggle_chat()
end, { desc = "AI Helper" })

map("n", "<leader>cO", function()
  require("codecompanion").chat()
end, { desc = "AI Helper (new chat)" })

map("n", "<leader>ch", function()
  Snacks.terminal.open({ "chronos" }, {
    cwd = require("lazyvim.util").root.get(),
    border = "rounded",
    title = "Chronos",
    title_pos = "center",
  })
end, { desc = "Chronos" })

map("n", "<C-d>", "<C-d>zz", { silent = true })
map("n", "<C-u>", "<C-u>zz", { silent = true })
map("n", "<leader><tab>h", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<leader><tab>l", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>g", "<cmd>tablast<cr>", { desc = "Last Tab" })

map("n", "<leader><leader>", function()
  require("snacks.picker").files()
end, { desc = "Find Files (cwd)" })
