return {
  "EdenEast/nightfox.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("carbonfox")
    vim.cmd("highlight! WinSeparator guifg=#4BC3B1")
  end,
}
