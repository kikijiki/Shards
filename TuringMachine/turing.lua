function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function parseInput(input, separator)
  local ret = {}
  local i = 1
  
  if separator then
    for _,v in pairs(input:split(separator)) do
      ret[i] = v
      i = i + 1
    end
  else
    for c in input:gmatch(".") do
      ret[i] = c
      i = i + 1
    end
  end
  
  return ret
end

function parseTM(tm)
  tm.input = parseInput(tm.input.tape, tm.input.separator)
  
  for _,v in pairs(tm.Qf) do tm.Qf[v] = v end
  for _,v in pairs(tm.Qa) do tm.Qa[v] = v end
  
  tm.state = { q = tm.q0, pos = 1 }
  
  local tmp = {}
  for k,v in pairs(tm.transitions) do tmp[k] = v end
  
  tm.transitions = {}
  for _,v in pairs(tmp) do
    local data = v:split(",")
    if not tm.transitions[data[1]] then tm.transitions[data[1]] = {} end
    tm.transitions[data[1]][data[2]] = {data[3], data[4], data[5]}
  end
end

local function printState(tm)  
  for i = 1, #tm.input, 1 do
    if i == tm.state.pos then
      io.write("* Q:"..tm.state.q)
      break
    else io.write(" ") end
  end
  
  io.write("\n")
  
  for i = 1, #tm.input, 1 do
    io.write(tm.input[i])
  end
  
  io.write("\n")
end

local function nextSymbol(tm)
  if not tm.input[tm.state.pos] then
    tm.input[tm.state.pos] = tm.empty
  end
  return tm.input[tm.state.pos]
end

local function step(tm)
  local state = tm.state.q
  
  if tm.Qa[state] then
    print("\nReached [ACCEPT] state ("..state..")")
    return false
  end
  
  if tm.Qf[state] then
    print("\nReached [FAIL] state ("..state..")")
    return false
  end

  local symbol = nextSymbol(tm)
  local op = tm.transitions[state][symbol]
  
  tm.state.q = op[1]
  tm.input[tm.state.pos] = op[2]
  
  if op[3] == "R" then
    tm.state.pos = tm.state.pos + 1
  else
    tm.state.pos = tm.state.pos - 1
  end
  
  if tm.state.pos < 1 then
    print("Reached the end of the tape (negative index)")
    error()
  end
  
  return true
end

local function executeTM(tm)
  printState(tm)
  local steps = 0;
  
  while true do
    if not step(tm) then break end
    printState(tm)
    steps = steps + 1
  end
  
  print(steps.." iterations")
end

local function loadTM(src, out)
  out.tm = dofile(src)
end

local function main()
  local src = arg[1];
  local data = {}
  
  if not src then
    print("No input")
    return
  end
  
  local status, err = pcall(loadTM, src, data)  
  if status then
    parseTM(data.tm)
    executeTM(data.tm)
  else
	print(src.." is not valid.")
	print(err)
  end
end

main()