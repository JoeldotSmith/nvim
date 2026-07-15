local renderer = require("codecompanion_orb.renderer")

local M = {}
local Widget = {}
Widget.__index = Widget

local uv = vim.uv or vim.loop
local namespace = vim.api.nvim_create_namespace("codecompanion_orb")

local DEFAULTS = {
  height = 12,
  fps = 18,
  detail = 2,
  initial_intensity = 0,
  min_width = 12,
  highlights = {
    normal = { fg = "#44e4f2", bg = "NONE" },
    depth = {
      { fg = "#06263f" },
      { fg = "#0b4268" },
      { fg = "#126b93" },
      { fg = "#0099b8" },
      { fg = "#22cee0" },
      { fg = "#66f6ff" },
      { fg = "#d2ffff", bold = true },
    },
  },
}

local function set_buf_option(buf, name, value)
  pcall(vim.api.nvim_set_option_value, name, value, { buf = buf })
end

local function set_win_option(win, name, value)
  pcall(vim.api.nvim_set_option_value, name, value, { win = win })
end

local function valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

function M.setup_highlights(opts)
  opts = vim.tbl_deep_extend("force", DEFAULTS.highlights, opts or {})
  vim.api.nvim_set_hl(0, "CodeCompanionOrbNormal", opts.normal)

  for index, hl in ipairs(opts.depth) do
    vim.api.nvim_set_hl(0, "CodeCompanionOrbDepth" .. index, hl)
  end
end

function Widget.new(opts)
  opts = vim.tbl_deep_extend("force", DEFAULTS, opts or {})

  local self = setmetatable({}, Widget)
  self.opts = opts
  self.height = opts.height
  self.fps = opts.fps
  self.intensity = opts.initial_intensity
  self.target_intensity = opts.initial_intensity
  self.started_at = uv.hrtime() / 1e9
  self.last_lines = nil
  self.closed = false
  self.renderer = renderer.new({
    width = opts.width or 36,
    height = opts.height,
    detail = opts.detail,
    idle_amplitude = opts.idle_amplitude,
    talking_amplitude = opts.talking_amplitude,
    idle_rotation_speed = opts.idle_rotation_speed,
    talking_rotation_speed = opts.talking_rotation_speed,
    noise_scale = opts.noise_scale,
    noise_speed = opts.noise_speed,
    noise_octaves = opts.noise_octaves,
    perspective = opts.perspective,
    camera_distance = opts.camera_distance,
    scale = opts.scale,
  })

  return self
end

function Widget:configure_buffer()
  self.buf = vim.api.nvim_create_buf(false, true)
  set_buf_option(self.buf, "buftype", "nofile")
  set_buf_option(self.buf, "bufhidden", "wipe")
  set_buf_option(self.buf, "swapfile", false)
  set_buf_option(self.buf, "modifiable", false)
  set_buf_option(self.buf, "filetype", "codecompanion-orb")
  vim.api.nvim_buf_set_name(self.buf, "CodeCompanion Orb")
end

function Widget:configure_window()
  set_win_option(self.win, "number", false)
  set_win_option(self.win, "relativenumber", false)
  set_win_option(self.win, "signcolumn", "no")
  set_win_option(self.win, "foldcolumn", "0")
  set_win_option(self.win, "statuscolumn", "")
  set_win_option(self.win, "cursorline", false)
  set_win_option(self.win, "cursorcolumn", false)
  set_win_option(self.win, "list", false)
  set_win_option(self.win, "wrap", false)
  set_win_option(self.win, "spell", false)
  set_win_option(self.win, "winfixheight", true)
  set_win_option(self.win, "winfixwidth", true)
  set_win_option(
    self.win,
    "winhl",
    "Normal:CodeCompanionOrbNormal,NormalNC:CodeCompanionOrbNormal,EndOfBuffer:CodeCompanionOrbNormal"
  )
  set_win_option(self.win, "statusline", " ")
  pcall(vim.api.nvim_win_set_height, self.win, self.height)
end

function Widget:open_split(anchor_win)
  if not valid_win(anchor_win) then
    return false
  end

  local previous_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(anchor_win)
  vim.cmd(("noautocmd aboveleft %dsplit"):format(self.height))
  self.win = vim.api.nvim_get_current_win()
  self:configure_buffer()
  vim.api.nvim_win_set_buf(self.win, self.buf)
  self:configure_window()
  self:start()

  if valid_win(anchor_win) then
    vim.api.nvim_set_current_win(anchor_win)
  elseif valid_win(previous_win) then
    vim.api.nvim_set_current_win(previous_win)
  end

  return true
end

function Widget:set_intensity(level)
  self.target_intensity = math.max(0, math.min(1, level or 0))
end

function Widget:render_once()
  if self.closed or not valid_win(self.win) or not valid_buf(self.buf) then
    self:stop()
    return
  end

  local width = math.max(self.opts.min_width, vim.api.nvim_win_get_width(self.win))
  self.renderer:set_size(width, self.height)
  self.intensity = self.intensity + (self.target_intensity - self.intensity) * 0.12

  local now = uv.hrtime() / 1e9
  local frame = self.renderer:render(now - self.started_at, self.intensity)

  set_buf_option(self.buf, "modifiable", true)

  if not self.last_lines or table.concat(self.last_lines, "\n") ~= table.concat(frame.lines, "\n") then
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, frame.lines)
    self.last_lines = frame.lines
  end

  vim.api.nvim_buf_clear_namespace(self.buf, namespace, 0, -1)
  for row, spans in ipairs(frame.highlights) do
    for _, span in ipairs(spans) do
      vim.api.nvim_buf_add_highlight(
        self.buf,
        namespace,
        "CodeCompanionOrbDepth" .. span.level,
        row - 1,
        span.col,
        span.end_col
      )
    end
  end

  set_buf_option(self.buf, "modifiable", false)
end

function Widget:start()
  if self.timer then
    return
  end

  self:render_once()
  self.timer = uv.new_timer()
  self.timer:start(0, math.floor(1000 / self.fps), function()
    vim.schedule(function()
      if not self.closed then
        self:render_once()
      end
    end)
  end)
end

function Widget:stop()
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
  end
end

function Widget:close()
  self.closed = true
  self:stop()

  if valid_win(self.win) then
    pcall(vim.api.nvim_win_close, self.win, true)
  end

  if valid_buf(self.buf) then
    pcall(vim.api.nvim_buf_delete, self.buf, { force = true })
  end
end

M.Widget = Widget

function M.new(opts)
  return Widget.new(opts)
end

return M
