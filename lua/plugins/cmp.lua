return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    opts.experimental = { ghost_text = true }

    -- Add Supermaven source at the top
    table.insert(opts.sources, 1, { name = "supermaven" })
  end,
}
