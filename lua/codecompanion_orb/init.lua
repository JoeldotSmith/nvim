local widget = require("codecompanion_orb.widget")

local M = {}

local state = {
  opts = nil,
  attachments = {},
  intensity = 0,
}

local DEFAULTS = {
  auto_attach = true,
  commands = true,
  height_ratio = 0.4,
  min_height = 8,
  max_height = 18,
  min_chat_height = 10,
  fps = 18,
  detail = 2,
  min_width = 12,
}

local function clamp(value, min_value, max_value)
  if value < min_value then
    return min_value
  end
  if value > max_value then
    return max_value
  end
  return value
end

local function valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function codecompanion_buf(buf)
  return valid_buf(buf) and vim.bo[buf].filetype == "codecompanion"
end

local function find_chat_win(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local win_buf = vim.api.nvim_win_get_buf(win)
    if (not buf or win_buf == buf) and codecompanion_buf(win_buf) then
      return win, win_buf
    end
  end
end

local function resolve_target(target)
  if type(target) == "table" then
    if valid_win(target.win) then
      return target.win, vim.api.nvim_win_get_buf(target.win)
    end
    if valid_buf(target.buf) then
      return find_chat_win(target.buf)
    end
  elseif type(target) == "number" then
    if valid_win(target) then
      return target, vim.api.nvim_win_get_buf(target)
    end
    if valid_buf(target) then
      return find_chat_win(target)
    end
  end

  return find_chat_win()
end

local function cleanup_attachment(chat_win, close_orb)
  local attachment = state.attachments[chat_win]
  if not attachment then
    return
  end

  state.attachments[chat_win] = nil
  if close_orb then
    attachment.widget:close()
  else
    attachment.widget:stop()
  end

  if attachment.group then
    pcall(vim.api.nvim_del_augroup_by_id, attachment.group)
  end
end

local function create_lifecycle_autocmds(chat_win, chat_buf, orb)
  local group = vim.api.nvim_create_augroup("CodeCompanionOrb" .. chat_win, { clear = true })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(chat_win),
    callback = function()
      vim.schedule(function()
        cleanup_attachment(chat_win, true)
      end)
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(orb.win),
    callback = function()
      vim.schedule(function()
        cleanup_attachment(chat_win, false)
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    buffer = chat_buf,
    callback = function()
      vim.schedule(function()
        cleanup_attachment(chat_win, true)
      end)
    end,
  })

  return group
end

local function resolve_orb_height(opts, chat_win)
  if opts.height then
    return math.max(1, math.floor(opts.height))
  end

  local chat_height = vim.api.nvim_win_get_height(chat_win)
  local available = math.max(3, chat_height - opts.min_chat_height)
  local target = math.floor(chat_height * opts.height_ratio + 0.5)
  target = clamp(target, opts.min_height, opts.max_height)
  return math.min(target, available)
end

local function schedule_attach(target, attempts)
  attempts = attempts or 8

  vim.schedule(function()
    if M.attach(target) or attempts <= 1 then
      return
    end

    vim.defer_fn(function()
      schedule_attach(target, attempts - 1)
    end, 25)
  end)
end

function M.setup(opts)
  state.opts = vim.tbl_deep_extend("force", DEFAULTS, opts or {})
  widget.setup_highlights(state.opts.highlights)

  local group = vim.api.nvim_create_augroup("CodeCompanionOrb", { clear = true })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      widget.setup_highlights(state.opts.highlights)
    end,
  })

  if state.opts.auto_attach then
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "codecompanion",
      callback = function(ev)
        schedule_attach({ buf = ev.buf })
      end,
    })
  end

  if state.opts.commands then
    pcall(vim.api.nvim_create_user_command, "CodeCompanionOrbAttach", function()
      M.attach()
    end, {})

    pcall(vim.api.nvim_create_user_command, "CodeCompanionOrbIntensity", function(command)
      M.set_intensity(tonumber(command.args) or 0)
    end, {
      nargs = "?",
      complete = function()
        return { "0", "0.25", "0.5", "0.75", "1" }
      end,
    })
  end
end

function M.attach(target, opts)
  if not state.opts then
    M.setup({ auto_attach = false })
  end

  local chat_win, chat_buf = resolve_target(target)
  if not valid_win(chat_win) or not codecompanion_buf(chat_buf) then
    return nil
  end

  local existing_orb_win = vim.w[chat_win].codecompanion_orb_win
  if valid_win(existing_orb_win) then
    return state.attachments[chat_win] and state.attachments[chat_win].widget
  end

  cleanup_attachment(chat_win, true)

  local orb_opts = vim.tbl_deep_extend("force", state.opts, opts or {})
  orb_opts.height = resolve_orb_height(orb_opts, chat_win)

  local orb = widget.new(vim.tbl_deep_extend("force", orb_opts, {
    initial_intensity = state.intensity,
  }))

  if not orb:open_split(chat_win) then
    return nil
  end

  vim.w[chat_win].codecompanion_orb_win = orb.win
  vim.w[orb.win].codecompanion_orb_chat_win = chat_win

  local lifecycle_group = create_lifecycle_autocmds(chat_win, chat_buf, orb)
  state.attachments[chat_win] = {
    widget = orb,
    group = lifecycle_group,
  }

  return orb
end

function M.set_intensity(level)
  state.intensity = math.max(0, math.min(1, level or 0))
  for _, attachment in pairs(state.attachments) do
    attachment.widget:set_intensity(state.intensity)
  end
end

function M.chat(...)
  local ok, codecompanion = pcall(require, "codecompanion")
  if not ok then
    vim.notify("codecompanion.nvim is not available", vim.log.levels.WARN)
    return nil
  end

  local result = codecompanion.chat(...)
  schedule_attach(nil)
  return result
end

function M.toggle_chat(...)
  local ok, codecompanion = pcall(require, "codecompanion")
  if not ok then
    vim.notify("codecompanion.nvim is not available", vim.log.levels.WARN)
    return nil
  end

  local result = codecompanion.toggle_chat(...)
  schedule_attach(nil)
  return result
end

return M
