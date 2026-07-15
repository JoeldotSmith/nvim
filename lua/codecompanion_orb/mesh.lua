local M = {}

local function normalize(v)
  local len = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
  return { x = v.x / len, y = v.y / len, z = v.z / len }
end

local function edge_key(a, b)
  if a < b then
    return a .. ":" .. b
  end
  return b .. ":" .. a
end

local function add_midpoint(vertices, cache, a, b)
  local key = edge_key(a, b)
  local cached = cache[key]
  if cached then
    return cached
  end

  local va = vertices[a]
  local vb = vertices[b]
  local vertex = normalize({
    x = (va.x + vb.x) * 0.5,
    y = (va.y + vb.y) * 0.5,
    z = (va.z + vb.z) * 0.5,
  })

  vertices[#vertices + 1] = vertex
  cache[key] = #vertices
  return #vertices
end

function M.icosphere(detail)
  detail = math.max(0, math.floor(detail or 2))

  local t = (1 + math.sqrt(5)) / 2
  local vertices = {
    normalize({ x = -1, y = t, z = 0 }),
    normalize({ x = 1, y = t, z = 0 }),
    normalize({ x = -1, y = -t, z = 0 }),
    normalize({ x = 1, y = -t, z = 0 }),
    normalize({ x = 0, y = -1, z = t }),
    normalize({ x = 0, y = 1, z = t }),
    normalize({ x = 0, y = -1, z = -t }),
    normalize({ x = 0, y = 1, z = -t }),
    normalize({ x = t, y = 0, z = -1 }),
    normalize({ x = t, y = 0, z = 1 }),
    normalize({ x = -t, y = 0, z = -1 }),
    normalize({ x = -t, y = 0, z = 1 }),
  }

  local faces = {
    { 1, 12, 6 },
    { 1, 6, 2 },
    { 1, 2, 8 },
    { 1, 8, 11 },
    { 1, 11, 12 },
    { 2, 6, 10 },
    { 6, 12, 5 },
    { 12, 11, 3 },
    { 11, 8, 7 },
    { 8, 2, 9 },
    { 4, 10, 5 },
    { 4, 5, 3 },
    { 4, 3, 7 },
    { 4, 7, 9 },
    { 4, 9, 10 },
    { 5, 10, 6 },
    { 3, 5, 12 },
    { 7, 3, 11 },
    { 9, 7, 8 },
    { 10, 9, 2 },
  }

  for _ = 1, detail do
    local midpoint_cache = {}
    local next_faces = {}

    for _, face in ipairs(faces) do
      local a, b, c = face[1], face[2], face[3]
      local ab = add_midpoint(vertices, midpoint_cache, a, b)
      local bc = add_midpoint(vertices, midpoint_cache, b, c)
      local ca = add_midpoint(vertices, midpoint_cache, c, a)

      next_faces[#next_faces + 1] = { a, ab, ca }
      next_faces[#next_faces + 1] = { b, bc, ab }
      next_faces[#next_faces + 1] = { c, ca, bc }
      next_faces[#next_faces + 1] = { ab, bc, ca }
    end

    faces = next_faces
  end

  local seen_edges = {}
  local edges = {}
  for _, face in ipairs(faces) do
    local pairs = {
      { face[1], face[2] },
      { face[2], face[3] },
      { face[3], face[1] },
    }

    for _, pair in ipairs(pairs) do
      local key = edge_key(pair[1], pair[2])
      if not seen_edges[key] then
        seen_edges[key] = true
        edges[#edges + 1] = { pair[1], pair[2] }
      end
    end
  end

  return {
    vertices = vertices,
    faces = faces,
    edges = edges,
  }
end

return M
