local function repo(path)
  return "https://github.com/" .. path
end

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local name = ev.data and ev.data.spec and ev.data.spec.name
    if name == "nvim-treesitter" and ev.data.kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  repo("nvim-lua/plenary.nvim"),
  repo("nvim-neotest/nvim-nio"),
  repo("MunifTanjim/nui.nvim"),
  repo("nvim-tree/nvim-web-devicons"),
  repo("echasnovski/mini.icons"),

  repo("EdenEast/nightfox.nvim"),
  repo("folke/snacks.nvim"),
  repo("sphamba/smear-cursor.nvim"),
  repo("folke/which-key.nvim"),
  repo("j-hui/fidget.nvim"),
  repo("lewis6991/gitsigns.nvim"),
  repo("folke/todo-comments.nvim"),
  repo("folke/flash.nvim"),
  repo("folke/trouble.nvim"),
  repo("folke/noice.nvim"),
  repo("nvim-lualine/lualine.nvim"),
  repo("akinsho/bufferline.nvim"),
  repo("folke/persistence.nvim"),
  repo("folke/lazydev.nvim"),

  { src = repo("nvim-treesitter/nvim-treesitter"), version = "main" },
  repo("nvim-treesitter/nvim-treesitter-textobjects"),
  repo("windwp/nvim-ts-autotag"),
  repo("JoosepAlviste/nvim-ts-context-commentstring"),

  repo("stevearc/conform.nvim"),
  repo("mfussenegger/nvim-lint"),
  repo("williamboman/mason.nvim"),
  repo("williamboman/mason-lspconfig.nvim"),
  repo("neovim/nvim-lspconfig"),
  repo("seblyng/roslyn.nvim"),

  repo("hrsh7th/nvim-cmp"),
  repo("hrsh7th/cmp-nvim-lsp"),
  repo("hrsh7th/cmp-buffer"),
  repo("hrsh7th/cmp-path"),
  repo("garymjr/nvim-snippets"),
  repo("rafamadriz/friendly-snippets"),
  repo("supermaven-inc/supermaven-nvim"),


  repo("olimorris/codecompanion.nvim"),
  repo("MeanderingProgrammer/render-markdown.nvim"),
  repo("lervag/vimtex"),
}, {
  confirm = #vim.api.nvim_list_uis() > 0,
  load = true,
})

