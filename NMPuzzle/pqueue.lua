local M = {}
M.__index = M

function M:new(compare, content)
  pq = {
    cmp = compare or (function(a, b) return a < b end),
    data = {},
    size = 0
  }
  setmetatable(pq, self)
  
  if content then
    for _,v in pairs(content) do pq:push(v) end
  end
  
  return pq;
end

function M:push(element)
  local data, cmp = self.data, self.cmp
  table.insert(data, element)
  if #data == 1 then
    self.size = self.size + 1
    return
  end
  
  local i = #data
  local j = #data - 1
  while j > 0 do
    if cmp(data[i], data[j]) then
      data[i], data[j] = data[j], data[i]
      i = i - 1
      j = j - 1
    else break end
  end
  
  self.size = self.size + 1
end

function M:pop()
  if(self.size > 0) then
    self.size = self.size - 1
  end
  return table.remove(self.data)
end

function M:isEmpty()
  return self.size == 0
end

return M;