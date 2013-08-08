local PriorityQueue = require "pqueue"

-- Pretty print of a state, or two consecutive states.
-- The function is not very pretty though.
function printState(digits, s1, s2)
  local format = "%"..digits.."u"
  local format2 = " "..format
  local half = math.floor(#s1 / 2)
  local blank = string.rep(" ", digits)
  local skip
  for i = 1, #s1 do
    io.write("|")
    skip = true
    for j = 1, #s1[1] do
      if s1[i][j] == 0 then io.write(blank..(skip and "" or " "))
      else io.write(string.format(skip and format or format2, s1[i][j])) end
      skip = false
    end
    if s2 then
      skip = true
      io.write((i==half) and "| => |" or "|    |")
      for j = 1, #s1[1] do
        if s2[i][j] == 0 then io.write(blank..(skip and "" or " "))
        else io.write(string.format(skip and format or format2, s2[i][j])) end
        skip = false
      end
    end
    io.write("|\n")
  end
end

-- Count how many tiles are different.
function diff(s1, s2)
  local diff = 0;
  for i,row in pairs(s1) do
    for j,v in pairs(row) do
      if v ~= s2[i][j] then diff = diff + 1 end
    end
  end
  return diff
end

-- Heuristic based on the number of wrong tiles.
function heuristic_misplaced(state, goal)
  return diff(state, goal)
end

-- Heuristic based on the manhattan distance of the tiles.
function heuristic_manhattan(state, goal)
  local ret = 0;
  for i,row in pairs(state) do
    for j,v in pairs(row) do
      if v ~= goal[i][j] then
        local x, y = find(goal, v)
        ret = ret +  math.abs(x - j) + math.abs(y - i)
      end
    end
  end
  return ret
end

-- The solution is found when the state is the same as the goal.
function achievedGoal(state, goal)
  return diff(state, goal) == 0
end

-- Print the solution.
function pathTo(digits, node)
  local buf = {}

  while node ~= nil do
    table.insert(buf, node)
    node = node.parent
  end

  print("Solution steps: "..(#buf - 1))
  local index = 1
  for i = #buf - 1, 1, -1 do
    local node1 = buf[i]
    local node2 = buf[i + 1]
    
    print(index..")"..node1.action)
    printState(digits, node2.state, node1.state)
    index = index + 1
  end

  io.write("end\n")
end

-- Find the coordinates of a tile given its value.
function find(state, value)
  for i,row in pairs(state) do
    for j,v in pairs(row) do
      if v == value then return j, i end
    end
  end
end

-- Create a copy of a state.
function clone(state)
  local ret = {}
  for _,row in pairs(state) do
    local newrow = {}
    for _,v in pairs(row) do table.insert(newrow, v) end
    table.insert(ret, newrow)
  end
  return ret
end

-- Swap two tiles.
function swap(state, x1, y1, x2, y2)
  local ret = clone(state)
  ret[y1][x1],ret[y2][x2] = ret[y2][x2],ret[y1][x1]
  return ret
end

-- Starting from a certain state, find all the allowed moves and relative final states.
function expand(node, goal, heuristic, columns, rows)
  local x, y = find(node.state, 0)
  local ret = {}

  if x > 1 then 
    table.insert(ret, makeNode(node, goal, heuristic, x, y, x - 1, y, "left")) end
  
  if x < columns then 
    table.insert(ret, makeNode(node, goal, heuristic, x, y, x + 1, y, "right")) end
  
  if y > 1 then 
    table.insert(ret, makeNode(node, goal, heuristic, x, y, x, y - 1, "up")) end
  
  if y < rows then 
    table.insert(ret, makeNode(node, goal, heuristic, x, y, x, y + 1, "down")) end

  return ret
end

-- Find the node obtained from applying a move to a parent node.
function makeNode(parent, goal, heuristic, x, y, nx, ny, action)
  local node = {}
  node.state = swap(parent.state, x, y, nx, ny)
  node.cost = parent.cost + 1
  node.h = node.cost + heuristic(node.state, goal)
  node.parent = parent;
  node.id = makeId(node.state)
  node.action = action
  return node
end

-- Create a unique identifier for a solution.
function makeId(state)
  local buf = {}
  for _, row in pairs(state) do
    for _, v in pairs(row) do
      table.insert(buf, v)
    end
  end
  return table.concat(buf, "-")
end

-- Randomly shuffle the puzzle from an initial state.
-- Because we only move the blank tile, the resulting state will always be reachable.
function shuffle(state, times)
  math.randomseed(os.time())
  math.random() math.random() math.random() --!!
  
  local rows, columns = #state, #state[1]
  assert(rows > 1 and columns > 1, "Must be at least 2x2")
  
  local ret = clone(state)
  local x, y = find(state, 0)
  
  local moves = {{-1,0,"left"},{1,0,"right"},{0,1,"down"},{0,-1,"up"}}
  print("Shuffling")
  local list = {}
  for _ = 1, times do
    while true do
      local dir = math.random(4)
      local x2 = x + moves[dir][1]
      local y2 = y + moves[dir][2]
      if not(x2 < 1 or x2 > columns or y2 < 1 or y2 > rows) then
        ret[y][x], ret[y2][x2] = ret[y2][x2], ret[y][x]
        table.insert(list, moves[dir][3])
        x = x2
        y = y2
        break
      end
    end
  end
  print(table.concat(list, ","))
  return ret
end

-- Make a state of the given dimentions, with all the tiles in order.
function makeGoal(row, col)
  local ret = {}
  local v = 0
  for _ = 1, row do
    local newrow = {}
    for _ = 1, col do
      table.insert(newrow, v)
      v = v + 1
    end
    table.insert(ret, newrow)
  end
  return ret
end

function printStats(start)
  print("Elapsed time", (os.clock() - start).."S")
  
  local memory = collectgarbage("count")
  if memory < 1024 then
    print("Memory", string.format("%.0u", memory).."KiB")
  else
    print("Memory", string.format("%.0u", memory / 1024).."MiB")
  end
end

-- The main algorithm.
function aStar(s0, goal, heuristic)
  -- Use a Lua associative table to keep track of the visited states.
  local visited = {}
  -- The priority queue will sort the solutions in order to have decreasing cost.
  local fringe  = PriorityQueue:new(function (node1, node2) return node1.h > node2.h end)
  -- Extract the problem dimensions from the initial state (length of the first row and column).
  local rows, columns = #s0, #s0[1]
  -- Find the number of digits required to print the solutions to the console correctly aligned.
  local digits = math.ceil(math.log(rows * columns, 10))
  
  assert(rows == #goal and columns == #goal[1], "Goal and initial state dimensions does not match.")
  
  local node0 = {
    state = s0, 
    cost = 0, 
    h = heuristic(s0, goal), 
    parent = nil, 
    id = makeId(s0), 
    action = "start"
  }

  fringe:push(node0)
  visited[node0.id] = true
  
  print("Searching...")
  local start = os.clock()

  while not fringe:isEmpty() do
    local top = fringe:pop()
    
    if achievedGoal(top.state, goal) then
      print("Initial state and goal state")
      printState(digits, s0, goal)
      pathTo(digits, top)
      printStats(start)
      return
    end

    local subnodes = expand(top, goal, heuristic, columns, rows)
    for _,node in pairs(subnodes) do
      if not visited[node.id] then
        visited[node.id] = true
        fringe:push(node)
      end
    end
  end

  print("No solution found")
  printStats(start)
end

-- Specify a goal manually.
--[[
local goal = {
  {0, 1, 2},
  {3, 4, 5},
  {6, 7, 8},
  {9,10,11}}]]

-- Make a default goal state.
-- Problem with 4 columns and 3 rows, standard order (blank, 1, 2, ...)
local goal = makeGoal(4, 3)
  
-- Specify an initial state manually.
--[[
local s0 = {
  {0, 1, 2},
  {3, 4, 5},
  {6, 7, 8},
  {9,10,11}}]]
  
-- Make a random initial state.
-- The higher the shuffles the more the solution is long, ideally.
local s0 = shuffle(goal, 20)
aStar(s0, goal, heuristic_manhattan)
