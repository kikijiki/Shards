if not arg or #arg < 3 then
  print("Usage: lua generate.lua <path to output> <budget> <number of items>")
  return
end

local file = io.open(arg[1], "w")

file:write(arg[2].."\n")

local food_names = {
  "birthday cake","wedding cake","Christmas cake","chocolate cake","coffee cake",
  "blueberry muffin","oatmeal cookie","chocolate cookie","crackers","biscuits","toast",
  "pasta","macaroni","noodles","spaghetti",
  "beef", "pork", "veal", "lamb",
  "beef steak", "roast beef", "ground beef", "hamburgers", "pork chops", "lamb chops",
  "salmon", "cod", "tuna", "sole",
  "apple", "pear", "apricot", "peach", "nectarine", "plum", "grapes", "cherry", "sweet cherry",
  "chicken breast", "turkey breast", "eggs",
  "ice cream", "vanilla ice cream", "chocolate ice cream",
  "milk", "yogurt", "cream", "sour cream", "butter",
  "ham", "bacon", "sausage", "hot dogs"
}

local cost_range = {min = 100, max = 1000}
local time_range = {min =   0, max =   60}

local name_index = 0
local name_buffer = nil

function shuffle(array)
  local n, random = #array, math.random
  for _ = 1, n do
    local j,k = random(n), random(n)
    array[j],array[k] = array[k],array[j]
  end
  return array
end

-- First use the available names. When they are exhausted, reuse them again but with incrementing suffix.
function generateNames()
  name_buffer = {}
  local suffix = ""
  
  if name_index > 0 then suffix = "("..name_index..")" end
  
  for _,v in pairs(food_names) do
    table.insert(name_buffer, v..suffix)
  end
  
  shuffle(name_buffer)
end

-- Get the next available name. When all are exhausted, generate new names.
function nextName()
  if not name_buffer then generateNames() end
  local name = table.remove(name_buffer)
  if #name_buffer == 0 then
    generateNames()
    name_index = name_index + 1
  end
  return name
end

math.randomseed(os.time())

for _ = 1, arg[3] do
  local name = nextName()
  local cost = math.random(cost_range.min, cost_range.max)
  local time = math.random(time_range.min, time_range.max)
  time = math.max(time_range.min,
    math.floor(time * (cost / cost_range.max)))

  file:write(name..","..cost..","..-time.."\n")  
end

file:close()

print("OK")