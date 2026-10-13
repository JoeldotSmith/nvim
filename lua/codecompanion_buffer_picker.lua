local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "CodeCompanion" })
end

local function can_send_code()
  local ok, config = pcall(require, "codecompanion.config")
  if ok and config.can_send_code and not config.can_send_code() then
    notify("Sending code to CodeCompanion is disabled", vim.log.levels.WARN)
    return false
  end
  return true
end

local function get_chat(codecompanion)
  local chat
  if vim.bo.filetype == "codecompanion" and codecompanion.buf_get_chat then
    chat = codecompanion.buf_get_chat(0)
  end

  if not chat and codecompanion.last_chat then
    chat = codecompanion.last_chat()
  end

  if not chat then
    chat = codecompanion.chat({ stop_context_insertion = true })
  end

  if not chat then
    notify("Could not create a CodeCompanion chat", vim.log.levels.WARN)
  end

  return chat
end

local function context_id(path)
  return "<buf>" .. vim.fn.fnamemodify(path, ":.") .. "</buf>"
end

local function has_context(chat, id)
  for _, item in ipairs(chat.context_items or {}) do
    if item.id == id then
      return true
    end
  end
  return false
end

local function add_buffers(items)
  if not can_send_code() then
    return
  end

  local codecompanion_ok, codecompanion = pcall(require, "codecompanion")
  if not codecompanion_ok then
    notify("codecompanion.nvim is not available", vim.log.levels.WARN)
    return
  end

  local editor_context_ok, buffer_context = pcall(require, "codecompanion.interactions.shared.editor_context.buffer")
  if not editor_context_ok then
    notify("CodeCompanion buffer context is not available", vim.log.levels.WARN)
    return
  end

  local chat = get_chat(codecompanion)
  if not chat then
    return
  end

  local context = buffer_context.new({ Chat = chat })
  local added = 0
  local skipped = 0

  for _, item in ipairs(items) do
    local bufnr = item and item.buf
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      local path = vim.api.nvim_buf_get_name(bufnr)
      local filetype = vim.bo[bufnr].filetype

      if path == "" or filetype == "codecompanion" then
        skipped = skipped + 1
      elseif has_context(chat, context_id(path)) then
        skipped = skipped + 1
      else
        context:chat_render({ bufnr = bufnr })
        added = added + 1
      end
    end
  end

  if chat.ui then
    chat.ui:open()
  end

  if added == 0 then
    notify("No new buffers added to the chat", vim.log.levels.WARN)
  else
    local suffix = skipped > 0 and ("; skipped " .. skipped) or ""
    notify(("Added %d buffer%s to the chat%s"):format(added, added == 1 and "" or "s", suffix))
  end
end

function M.pick()
  local snacks_ok, picker = pcall(require, "snacks.picker")
  if not snacks_ok then
    notify("snacks.nvim picker is not available", vim.log.levels.WARN)
    return
  end

  picker.buffers({
    title = "CodeCompanion Buffers",
    current = true,
    unloaded = false,
    nofile = false,
    layout = { preset = "dropdown", preview = false },
    formatters = {
      selected = {
        show_always = true,
      },
    },
    confirm = function(p)
      local selected = p:selected({ fallback = true })
      p:close()
      vim.schedule(function()
        add_buffers(selected)
      end)
    end,
  })
end

return M
