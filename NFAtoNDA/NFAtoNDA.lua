local function equals(q1, q2)
  if type(q1) ~= type(q2) then return false end
  
  if type(q1) == "table" then
    for k, v in pairs( q1 ) do
      if q2[k] ~= v then return false end
    end
    for k, v in pairs( q2 ) do
      if q1[k] ~= v then return false end
    end
    return true
  else
    return q1 == q2
  end
end

local function contains(states, q)
  for _,v in pairs(states) do
    if equals(v, q) then return true end
  end
  
  return false
end

-- Convert table to string
local function formatTable(q)
  local ret = "{"
  local first = true
  for _,v in pairs(q) do
    if first then
      ret = ret..v
      first = false
    else 
      ret = ret..","..v 
    end
  end
  return ret.."}"
end

-- Convert table of tables to string
local function formatTables(q)
  local ret = "{"
  local first = true
  for _,v in pairs(q) do
    if first then
      ret = ret..formatTable(v)
      first = false
    else 
      ret = ret..","..formatTable(v)
    end
  end
  return ret.."}"
end

local function printAutomaton(a)
  print("Q = "..formatTables(a.Q))
  print("q0 = "..formatTable(a.q0))
  print("A = "..formatTable(a.A))
  print("Qa = "..formatTables(a.Qa))
  print("transitions:")
  for k,v in pairs(a.transitions) do
    for _,a in pairs(v) do
      local character = a[1] or "epsilon"
      print(formatTable(k).."-["..character.."]->"..formatTable(a[2]));
    end
  end
end

-- Epsilon closure 
-- q = table of states
-- c = closure, initially empty
local function e_closure(nfa, state, c)
  c = c or {}
  
  for _, q in pairs(state) do
    c[q] = q
    for _,a in pairs(nfa.transitions[q]) do
      if a[1] == nil then -- nil means ε
        c[a[2]] = a[2];
        e_closure(nfa, {a[2]}, c)
      end
    end
  end
  
  table.sort(c)
  return c
end

-- Prepare the empty dfa and add the initial state
local function initialize(nfa)
    local dfa = {Q={}, Qa={}, transitions={}, todo={}, A=nfa.A}
  
  local q0 = e_closure(nfa, {nfa.q0})
  
  dfa.q0 = q0
  dfa.Q[q0] = q0
  dfa.todo[q0] = q0
  dfa.todo_size = 1
  
  return dfa
end

-- Find the possible next states of a set of states
--   q = table of states
--   a = character 
-- ret = table of successor states
local function nextState(nfa, state, a)
    print("Finding successor states of "..formatTable(state))
    local ret = {}
  
  for _,q in pairs(state) do
    for _,v in pairs(nfa.transitions[q]) do
      if v[1] == a then
        print("Found "..q.."-["..a.."]->"..v[2])
        table.insert(ret, v[2])
      end
    end
  end

  return ret
end

-- Process a state of the automaton for a character
local function process(nfa, dfa, state, a)
  local succ = e_closure(nfa, nextState(nfa, state, a))
  
  if not next(succ, nil) then return end

  if not contains(dfa.Q, succ) and not contains(dfa.todo, succ) then
    dfa.todo[succ] = succ;
    dfa.todo_size = dfa.todo_size + 1
  end
  
  dfa.transitions[state] = dfa.transitions[state] or {}
  table.insert(dfa.transitions[state], {a, succ})
end

local function pop(t)
  local key, value = next(t, nil)
  t[key] = nil
  return value
end

-- Conversion algorithm
local function convert(nfa)
  local dfa = initialize(nfa)

  while dfa.todo_size > 0 do
    local q = pop(dfa.todo)
    dfa.todo_size = dfa.todo_size - 1
    print("Picked "..formatTable(q).." from the todo list")
    dfa.Q[q] = q
    for _,a in pairs(nfa.A) do
      print("Processing input <"..a..">")
      process(nfa, dfa, q, a)
    end
  end
  
  for _,v in pairs(dfa.Q) do
    for _,q in pairs(v) do
      if contains(nfa.Qa, q) then table.insert(dfa.Qa, v) end
    end
  end
  
  return dfa
end

local function loadNfa(path, out)
  local nfa = dofile(path)
  out.nfa = nfa
end

local function main()
  local src = arg[1];
  local data = {}
  
  if not src then
    print("No input")
    return
  end
  
  local status, err = pcall(loadNfa, src, data)  
  if status then
    local dfa = convert(data.nfa)
	print("\nGenerated DFA:\n")
    printAutomaton(dfa)
  else
	print(src.." is not valid.")
	print(err)
  end
end

main()