local mesh = require("codecompanion_orb.mesh")
local noise = require("codecompanion_orb.noise")

local M = {}
local Renderer = {}
Renderer.__index = Renderer

local DOTS = {
  { x = 0, y = 0, bit = 1 },
  { x = 0, y = 1, bit = 2 },
  { x = 0, y = 2, bit = 4 },
  { x = 1, y = 0, bit = 8 },
  { x = 1, y = 1, bit = 16 },
  { x = 1, y = 2, bit = 32 },
  { x = 0, y = 3, bit = 64 },
  { x = 1, y = 3, bit = 128 },
}

local DEFAULTS = {
  width = 36,
  height = 12,
  detail = 2,
  animation_speed = 1,
  idle_amplitude = 0.07,
  thinking_amplitude = 0.11,
  talking_amplitude = 0.18,
  responding_amplitude = 0.22,
  idle_rotation_speed = 0.55,
  thinking_rotation_speed = 0.86,
  talking_rotation_speed = 1.55,
  responding_rotation_speed = 1.72,
  noise_scale = 1.85,
  noise_speed = 0.36,
  thinking_noise_speed = 0.22,
  responding_noise_speed = 0.64,
  noise_octaves = 3,
  thinking_pulse_speed = 2.6,
  thinking_sweep_speed = 1.45,
  responding_pulse_speed = 5.4,
  responding_shimmer_speed = 8.2,
  perspective = 2.65,
  camera_distance = 3.05,
  scale = 0.44,
  depth_contrast = 1.35,
  back_edge_opacity = 0.32,
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

local function mix(a, b, t)
  return a + (b - a) * t
end

local function round(value)
  return math.floor(value + 0.5)
end

local function pulse(value)
  return (math.sin(value) + 1) * 0.5
end

local function normalize_mode(mode)
  if mode == "thinking" or mode == "responding" then
    return mode
  end

  return "idle"
end

local function mode_params(opts, mode, time, intensity)
  local responding_amplitude = opts.responding_amplitude or opts.talking_amplitude
  local responding_rotation_speed = opts.responding_rotation_speed or opts.talking_rotation_speed

  if mode == "thinking" then
    local state_energy = math.max(intensity, 0.46)
    local breath = pulse(time * opts.thinking_pulse_speed)

    return {
      amplitude = mix(opts.idle_amplitude, opts.thinking_amplitude, state_energy) + breath * 0.016,
      rotation_speed = mix(opts.idle_rotation_speed, opts.thinking_rotation_speed, state_energy),
      noise_speed = opts.thinking_noise_speed,
      rotation_x = math.sin(time * 0.5) * 0.22 + 0.2 + breath * 0.07,
      rotation_y_offset = math.sin(time * 1.7) * 0.08,
      rotation_z = math.sin(time * 0.32) * 0.12,
      scale = opts.scale * (1 + breath * 0.035),
      energy = state_energy,
    }
  end

  if mode == "responding" then
    local state_energy = math.max(intensity, 0.78)
    local surge = pulse(time * opts.responding_pulse_speed)

    return {
      amplitude = mix(opts.idle_amplitude, responding_amplitude, state_energy) + surge * 0.032,
      rotation_speed = mix(opts.idle_rotation_speed, responding_rotation_speed, state_energy),
      noise_speed = opts.responding_noise_speed,
      rotation_x = math.sin(time * 0.9) * 0.36 + 0.2,
      rotation_y_offset = math.sin(time * 2.4) * 0.16,
      rotation_z = math.sin(time * 0.78) * 0.18,
      scale = opts.scale * (1 + surge * 0.05),
      energy = state_energy,
    }
  end

  return {
    amplitude = mix(opts.idle_amplitude, responding_amplitude, intensity),
    rotation_speed = mix(opts.idle_rotation_speed, responding_rotation_speed, intensity),
    noise_speed = opts.noise_speed,
    rotation_x = math.sin(time * 0.63) * mix(0.22, 0.36, intensity) + 0.18,
    rotation_y_offset = 0,
    rotation_z = math.sin(time * 0.37) * mix(0.07, 0.15, intensity),
    scale = opts.scale,
    energy = intensity,
  }
end

local function mode_radius_offset(opts, mode, time, vertex, energy)
  if mode == "thinking" then
    return math.sin(time * opts.thinking_pulse_speed + vertex.y * 5.5) * 0.018 * energy
  end

  if mode == "responding" then
    return noise.fbm3(vertex.x * 3.1 - time * 1.6, vertex.y * 2.7 + time * 0.9, vertex.z * 3.3, 2) * 0.07 * energy
  end

  return 0
end

local function mode_visibility(opts, mode, time, edge_index, sub_height, a, b, base_visibility)
  if mode == "thinking" then
    local edge_y = (a.y + b.y) * 0.5
    local sweep_center = (pulse(time * opts.thinking_sweep_speed) * 0.82 + 0.09) * sub_height
    local distance = math.abs(edge_y - sweep_center) / math.max(1, sub_height * 0.22)
    local boost = math.max(0, 1 - distance) * 0.58
    return clamp(base_visibility + boost, 0, 1.35)
  end

  if mode == "responding" then
    local depth = (a.depth + b.depth) * 0.5
    local shimmer = pulse(time * opts.responding_shimmer_speed + edge_index * 0.37 + depth * 4.4)
    return clamp(base_visibility * (0.72 + shimmer * 0.68), 0, 1.4)
  end

  return base_visibility
end

local function utf8_char(codepoint)
  if codepoint < 0x80 then
    return string.char(codepoint)
  end
  if codepoint < 0x800 then
    return string.char(0xC0 + math.floor(codepoint / 0x40), 0x80 + (codepoint % 0x40))
  end
  if codepoint < 0x10000 then
    return string.char(
      0xE0 + math.floor(codepoint / 0x1000),
      0x80 + (math.floor(codepoint / 0x40) % 0x40),
      0x80 + (codepoint % 0x40)
    )
  end

  return " "
end

local function depth_level(depth, visibility)
  local normalized = clamp((depth + 1) * 0.5, 0, 1)
  local shaped = normalized ^ 1.35
  local visible = visibility or 1
  return clamp(math.floor((shaped * 0.82 + visible * 0.18) * 6.999) + 1, 1, 7)
end

local function plot(depths, sub_width, sub_height, x, y, depth, visibility)
  local sx = round(x)
  local sy = round(y)
  if sx < 1 or sx > sub_width or sy < 1 or sy > sub_height then
    return
  end

  local index = (sy - 1) * sub_width + sx
  local score = depth + (visibility or 1) * 0.18
  if not depths[index] or score > depths[index].score then
    depths[index] = {
      depth = depth,
      score = score,
      visibility = visibility or 1,
    }
  end
end

local function rasterize_line(depths, sub_width, sub_height, a, b, visibility)
  local dx = b.x - a.x
  local dy = b.y - a.y
  local steps = math.max(math.abs(dx), math.abs(dy))

  if steps < 1 then
    plot(depths, sub_width, sub_height, a.x, a.y, a.depth, visibility)
    return
  end

  for step = 0, steps do
    local t = step / steps
    plot(depths, sub_width, sub_height, a.x + dx * t, a.y + dy * t, mix(a.depth, b.depth, t), visibility)
  end
end

local function rotate_x(vertex, angle)
  local c = math.cos(angle)
  local s = math.sin(angle)
  return {
    x = vertex.x,
    y = vertex.y * c - vertex.z * s,
    z = vertex.y * s + vertex.z * c,
  }
end

local function rotate_y(vertex, angle)
  local c = math.cos(angle)
  local s = math.sin(angle)
  return {
    x = vertex.x * c + vertex.z * s,
    y = vertex.y,
    z = -vertex.x * s + vertex.z * c,
  }
end

function M.pack_braille(width, height, sub_width, depths)
  local lines = {}
  local highlights = {}

  for cell_y = 0, height - 1 do
    local parts = {}
    local spans = {}
    local byte_col = 0

    for cell_x = 0, width - 1 do
      local mask = 0
      local best_depth = nil

      for _, dot in ipairs(DOTS) do
        local sx = cell_x * 2 + dot.x + 1
        local sy = cell_y * 4 + dot.y + 1
        local sample = depths[(sy - 1) * sub_width + sx]

        if sample then
          mask = mask + dot.bit
          if not best_depth or sample.score > best_depth.score then
            best_depth = sample
          end
        end
      end

      local char = mask == 0 and " " or utf8_char(0x2800 + mask)
      parts[#parts + 1] = char

      if best_depth then
        spans[#spans + 1] = {
          col = byte_col,
          end_col = byte_col + #char,
          level = depth_level(best_depth.depth, best_depth.visibility),
        }
      end

      byte_col = byte_col + #char
    end

    lines[#lines + 1] = table.concat(parts)
    highlights[#highlights + 1] = spans
  end

  return lines, highlights
end

function Renderer.new(opts)
  opts = vim.tbl_deep_extend("force", DEFAULTS, opts or {})

  local self = setmetatable({}, Renderer)
  self.opts = opts
  self.width = opts.width
  self.height = opts.height
  self.detail = opts.detail
  self.mesh = mesh.icosphere(self.detail)
  return self
end

function Renderer:set_size(width, height)
  self.width = math.max(1, math.floor(width or self.width))
  self.height = math.max(1, math.floor(height or self.height))
end

function Renderer:set_detail(detail)
  detail = math.max(0, math.floor(detail or self.detail))
  if detail == self.detail then
    return
  end

  self.detail = detail
  self.mesh = mesh.icosphere(detail)
end

function Renderer:render(time, intensity, mode)
  intensity = clamp(intensity or 0, 0, 1)
  mode = normalize_mode(mode)

  local width = self.width
  local height = self.height
  local sub_width = width * 2
  local sub_height = height * 4
  local depths = {}
  local projected = {}
  local opts = self.opts
  time = time * math.max(0, opts.animation_speed or 1)
  local params = mode_params(opts, mode, time, intensity)

  local rotation_y = time * params.rotation_speed + params.rotation_y_offset
  local rotation_x = params.rotation_x
  local rotation_z = params.rotation_z
  local scale = math.min(sub_width, sub_height) * params.scale
  local center_x = sub_width * 0.5 + 0.5
  local center_y = sub_height * 0.5 + 0.5
  local noise_time = time * params.noise_speed

  for index, vertex in ipairs(self.mesh.vertices) do
    local displacement = noise.fbm3(
      vertex.x * opts.noise_scale + noise_time,
      vertex.y * opts.noise_scale + noise_time * 0.73,
      vertex.z * opts.noise_scale - noise_time * 0.61,
      opts.noise_octaves
    )

    local radius = 1 + displacement * params.amplitude + mode_radius_offset(opts, mode, time, vertex, params.energy)
    local displaced = {
      x = vertex.x * radius,
      y = vertex.y * radius,
      z = vertex.z * radius,
    }

    local rotated = rotate_y(rotate_x(displaced, rotation_x), rotation_y)
    local cz = math.cos(rotation_z)
    local sz = math.sin(rotation_z)
    rotated = {
      x = rotated.x * cz - rotated.y * sz,
      y = rotated.x * sz + rotated.y * cz,
      z = rotated.z * opts.depth_contrast,
    }
    local perspective = opts.perspective / (opts.camera_distance - rotated.z)

    projected[index] = {
      x = center_x + rotated.x * perspective * scale,
      y = center_y - rotated.y * perspective * scale,
      depth = rotated.z,
    }
  end

  for edge_index, edge in ipairs(self.mesh.edges) do
    local a = projected[edge[1]]
    local b = projected[edge[2]]
    local average_depth = (a.depth + b.depth) * 0.5
    local visibility = mix(opts.back_edge_opacity, 1, clamp((average_depth + 1.35) / 2.7, 0, 1))
    visibility = mode_visibility(opts, mode, time, edge_index, sub_height, a, b, visibility)
    rasterize_line(depths, sub_width, sub_height, a, b, visibility)
  end

  local lines, highlights = M.pack_braille(width, height, sub_width, depths)
  return {
    lines = lines,
    highlights = highlights,
  }
end

M.Renderer = Renderer

function M.new(opts)
  return Renderer.new(opts)
end

return M
