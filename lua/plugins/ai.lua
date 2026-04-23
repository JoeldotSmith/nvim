return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "j-hui/fidget.nvim",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "codex",
        },
        inline = {
          adapter = "codex",
        },
      },
      display = {
        chat = {
          window = {
            layout = "vertical",
            position = "right",
            width = 75,
            full_height = true,
          },
          start_in_insert_mode = false,
        },
      },
      adapters = {},
    },
    config = function(_, opts)
      opts.adapters.acp = {}
      opts.adapters.acp.codex = function()
        return require("codecompanion.adapters").extend("codex", {
          defaults = {
            auth_method = "chatgpt",
          },
        })
      end

      require("codecompanion").setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "codecompanion",
        callback = function(args)
          vim.keymap.set("n", "<C-c>", function()
            require("codecompanion").toggle_chat()
          end, { buffer = args.buf, silent = true, desc = "Hide chat" })
        end,
      })

      local progress = require("fidget.progress")
      local handles = {}
      local group = vim.api.nvim_create_augroup("CodeCompanionFidget", {})

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionRequestStarted",
        group = group,
        callback = function(e)
          handles[e.data.id] = progress.handle.create({
            title = "CodeCompanion",
            message = "Thinking...",
            lsp_client = { name = e.data.adapter.formatted_name },
          })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionRequestFinished",
        group = group,
        callback = function(e)
          local h = handles[e.data.id]
          if h then
            h.message = e.data.status == "success" and "Done" or "Failed"
            h:finish()
            handles[e.data.id] = nil
          end
        end,
      })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },
}
