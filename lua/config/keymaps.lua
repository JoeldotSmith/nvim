-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local Util = require("lazyvim.util")

vim.keymap.del("n", "<leader><tab>[")
vim.keymap.del("n", "<leader><tab>]")
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>")

vim.api.nvim_create_user_command("DebugProject", function()
  require("plugins.csharp").debug_project()
end, {})

-- New mappings
--
-- lazysql
map("n", "<leader>cd", function()
  Util.terminal.open({ "lazysql" }, {
    cwd = Util.root.get(),
    ctrl_hjkl = false,
    border = "rounded",
    persistent = false,
    title = "Lazysql",
    title_pos = "center",
  })
end, { desc = "Lazysql" })

-- chronos
map("n", "<leader>ch", function()
  Util.terminal.open({ "chronos" }, {
    cwd = Util.root.get(),
    ctrl_hjkl = false,
    border = "rounded",
    persistent = false,
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
