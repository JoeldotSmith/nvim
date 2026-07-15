local colors = {
  bg = "#000000",
  surface = "#000a0d",
  elevated = "#001114",
  fg = "#b8fbff",
  dim = "#2a5a60",
  accent = "#00e5ff",
  accent_bright = "#7dffff",
  highlight = "#39ff88",
  alert = "#ff4444",
}

return {
  normal = {
    a = { fg = colors.bg, bg = colors.accent, gui = "bold" },
    b = { fg = colors.accent_bright, bg = colors.surface },
    c = { fg = colors.fg, bg = colors.bg },
  },
  insert = {
    a = { fg = colors.bg, bg = colors.highlight, gui = "bold" },
    b = { fg = colors.highlight, bg = colors.surface },
    c = { fg = colors.fg, bg = colors.bg },
  },
  visual = {
    a = { fg = colors.bg, bg = colors.accent_bright, gui = "bold" },
    b = { fg = colors.accent_bright, bg = colors.surface },
    c = { fg = colors.fg, bg = colors.bg },
  },
  replace = {
    a = { fg = colors.bg, bg = colors.alert, gui = "bold" },
    b = { fg = colors.alert, bg = colors.surface },
    c = { fg = colors.fg, bg = colors.bg },
  },
  command = {
    a = { fg = colors.bg, bg = colors.accent, gui = "bold" },
    b = { fg = colors.accent_bright, bg = colors.surface },
    c = { fg = colors.fg, bg = colors.bg },
  },
  terminal = {
    a = { fg = colors.bg, bg = colors.highlight, gui = "bold" },
    b = { fg = colors.highlight, bg = colors.surface },
    c = { fg = colors.fg, bg = colors.bg },
  },
  inactive = {
    a = { fg = colors.dim, bg = colors.bg },
    b = { fg = colors.dim, bg = colors.bg },
    c = { fg = colors.dim, bg = colors.bg },
  },
}
