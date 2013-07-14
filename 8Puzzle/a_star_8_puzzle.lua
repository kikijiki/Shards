PriorityQueue = require "loop.collection.PriorityQueue"

function diff(s1, s2)
  local diff = 0;

  for i = 1, #s1 do
    for j = 1, #s1[i] do
      if s1[i][j] ~= s2[i][j] then diff = diff + 1 end
    end
  end

  return diff
end

function heuristic_misplaced(s, g)
  return diff(s, g)
end

function heuristic_manhattan(s, g)
  local ret = 0;

  for i = 0, 8 do
    local x1, y1 = find(s, i)
    local x2, y2 = find(g, i)
    ret = ret + math.abs(x1 - x2) + math.abs(y1 - y2)
  end

  return ret
end

function achievedGoal(g, s)
  return diff(s, g) == 0
end

function pathTo(n)
  local buf = {}
  local node = n;

  while node ~= nil do
    table.insert(buf, node.action)
    node = node.parent
  end

  print("Solution steps", #buf - 1)

  if #buf > 100 then
    print("Too long")
    return
  end

  for i = #buf, 1, -1 do
    io.write(buf[i] .. ", ")
  end

  io.write("end\n")
end

function find(t, v)
  for i = 1, #t do
    for j = 1, #t[i] do
      if t[i][j] == v then return j, i end
    end
  end
end

function swap(n, x1, y1, x2, y2)
  local ret = {
    {n[1][1], n[1][2], n[1][3]},
    {n[2][1], n[2][2], n[2][3]},
    {n[3][1], n[3][2], n[3][3]}}

  ret[y1][x1] = n[y2][x2]
  ret[y2][x2] = n[y1][x1]
  return ret
end

function expand_h(n, g, h)
  local x, y = find(n.state, 0)
  local ret = {}

  if x > 1     then table.insert(ret, makeNode_h(n, g, h, x, y, x - 1, y, "left"))  end
  if x < #g[1] then table.insert(ret, makeNode_h(n, g, h, x, y, x + 1, y, "right")) end
  if y > 1     then table.insert(ret, makeNode_h(n, g, h, x, y, x, y - 1, "up"))    end
  if y < #g    then table.insert(ret, makeNode_h(n, g, h, x, y, x, y + 1, "down"))  end

  return ret
end

function expand(n, g)
  local x, y = find(n.state, 0)
  local ret = {}

  if x > 1     then table.insert(ret, makeNode(n, g, x, y, x - 1, y, "left"))  end
  if x < #g[1] then table.insert(ret, makeNode(n, g, x, y, x + 1, y, "right")) end
  if y > 1     then table.insert(ret, makeNode(n, g, x, y, x, y - 1, "up"))    end
  if y < #g    then table.insert(ret, makeNode(n, g, x, y, x, y + 1, "down"))  end

  return ret
end

function makeNode_h(parent, goal, h, x, y, nx, ny, action)
  local node = {}
  node.state = swap(parent.state, x, y, nx, ny)
  node.cost = parent.cost + 1
  node.h = node.cost + h(node.state, goal)
  node.parent = parent;
  node.id = makeId(node.state)
  node.action = action
  return node
end

function makeNode(parent, goal, x, y, nx, ny, action)
  local node = {}
  node.state = swap(parent.state, x, y, nx, ny)
  node.parent = parent;
  node.id = makeId(node.state)
  node.action = action
  return node
end

function makeId(s)
  return 1e9 +
    1e5 * s[2][1] + 1e4 * s[2][2] + 1e3 * s[2][3] +
    1e2 * s[3][1] + 1e1 * s[3][2] + 1e0 * s[3][3]
end

function printMatrix(m)
  print("ID: " .. makeId(m))
  io.write(m[1][1] .. " " .. m[1][2] .. " " .. m[1][3] .. "\n")
  io.write(m[2][1] .. " " .. m[2][2] .. " " .. m[2][3] .. "\n")
  io.write(m[3][1] .. " " .. m[3][2] .. " " .. m[3][3] .. "\n")
end

function aStar(s0, g, h)
  local state   = {};
  local visited = {};
  local fringe  = {};

  local node0 = {state = s0, cost = 0, h = h(s0, g), parent = nil, id = makeId(s0), action = "start"}

  PriorityQueue.enqueue(fringe, node0, 0)
  visited[node0.id] = true

  local profile = 0

  while PriorityQueue.empty(fringe) == false do
    top = PriorityQueue.dequeue(fringe)

    if achievedGoal(top.state, g) then
      pathTo(top)
      return
    end

    local subnodes = expand_h(top, g, h)

    for k, v in ipairs(subnodes) do
      if not (visited[v.id] == true) then
        visited[v.id] = true
        PriorityQueue.enqueue(fringe, v, v.h)
      end
    end
  end

  print("No solution found")
end

function depthFirst(s0, g)
  local state   = {};
  local visited = {};
  local fringe  = {};

  local node0 = {state = s0, parent = nil, id = makeId(s0), action = "start"}

  table.insert(fringe, node0)
  visited[node0.id] = true

  local profile = 0

  while next(fringe) ~= nil do
    top = table.remove(fringe)

    if achievedGoal(top.state, g) then
      pathTo(top)
      return
    end

    local subnodes = expand(top, g)

    for k, v in ipairs(subnodes) do
      if not (visited[v.id] == true) then
        visited[v.id] = true
        table.insert(fringe, v)
      end
    end
  end

  print("No solution found")
end

s0 = {
  {1,6,4},
  {8,7,0},
  {3,2,5}}

s1 = {
  {8,1,7},
  {4,5,6},
  {2,0,3}}

s2 = {
  {2,0,7},
  {3,4,8},
  {5,6,1}}

s4 = {
  {2,4,7},
  {3,0,8},
  {5,1,6}}

goal = {
  {0,1,2},
  {3,4,5},
  {6,7,8}}

goal2 = {
  {1,2,3},
  {4,5,6},
  {7,8,0}}

--depthFirst(s0, goal)
aStar(s0, goal2, heuristic_manhattan)

--q1 21
--q2 25
--q3 6274
--q4 5
--q5 5
