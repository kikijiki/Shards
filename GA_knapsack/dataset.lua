local M = {}

function split(str, pat)
  local t = {}
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
	  table.insert(t, cap)
    end
    last_end = e + 1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

function M.open(args)
  local path = nil
  if args and args[2] then
    path = args[2] 
  else
    print("Specify an input file.")
    return nil
  end
  
  local file = io.open(path, "r")

  if not file then
    print("Could not find the specified dataset file.")
    return nil
  end
  
  local lines = file:lines()
  
  local dataset = {
    budget = tonumber(lines()),
    items = {}
  }

  for line in (function() return lines() end) do
    local values = split(line, ",")
    table.insert(dataset.items, {
        name = values[1], 
        cost = tonumber(values[2]), 
        time = tonumber(values[3])})
  end
  
  dataset.size = #dataset.items
  
  return dataset
end

return M