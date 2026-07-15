local M = {}

local function build_permutation(seed)
  local p = {}
  for i = 0, 255 do
    p[i + 1] = i
  end

  local state = seed or 1337
  for i = 256, 2, -1 do
    state = (state * 1103515245 + 12345) % 2147483648
    local j = (state % i) + 1
    p[i], p[j] = p[j], p[i]
  end

  return p
end

local perm = build_permutation(982451653)

local function perm_at(i)
  return perm[(i % 256) + 1]
end

local function fade(t)
  return t * t * t * (t * (t * 6 - 15) + 10)
end

local function lerp(t, a, b)
  return a + t * (b - a)
end

local function grad(hash, x, y, z)
  local h = hash % 16
  local u = h < 8 and x or y
  local v

  if h < 4 then
    v = y
  elseif h == 12 or h == 14 then
    v = x
  else
    v = z
  end

  local a = (h % 2 == 0) and u or -u
  local b = (math.floor(h / 2) % 2 == 0) and v or -v
  return a + b
end

function M.perlin3(x, y, z)
  local xi = math.floor(x)
  local yi = math.floor(y)
  local zi = math.floor(z)

  local X = xi % 256
  local Y = yi % 256
  local Z = zi % 256

  x = x - xi
  y = y - yi
  z = z - zi

  local u = fade(x)
  local v = fade(y)
  local w = fade(z)

  local A = perm_at(X) + Y
  local AA = perm_at(A) + Z
  local AB = perm_at(A + 1) + Z
  local B = perm_at(X + 1) + Y
  local BA = perm_at(B) + Z
  local BB = perm_at(B + 1) + Z

  return lerp(
    w,
    lerp(
      v,
      lerp(u, grad(perm_at(AA), x, y, z), grad(perm_at(BA), x - 1, y, z)),
      lerp(u, grad(perm_at(AB), x, y - 1, z), grad(perm_at(BB), x - 1, y - 1, z))
    ),
    lerp(
      v,
      lerp(u, grad(perm_at(AA + 1), x, y, z - 1), grad(perm_at(BA + 1), x - 1, y, z - 1)),
      lerp(u, grad(perm_at(AB + 1), x, y - 1, z - 1), grad(perm_at(BB + 1), x - 1, y - 1, z - 1))
    )
  )
end

function M.fbm3(x, y, z, octaves)
  local value = 0
  local amplitude = 0.5
  local frequency = 1
  local norm = 0

  for _ = 1, octaves or 3 do
    value = value + M.perlin3(x * frequency, y * frequency, z * frequency) * amplitude
    norm = norm + amplitude
    amplitude = amplitude * 0.5
    frequency = frequency * 2
  end

  if norm == 0 then
    return 0
  end
  return value / norm
end

return M
