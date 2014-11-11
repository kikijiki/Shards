for a = 1, 1000 do
  for b = 1, a do
    local c = math.sqrt(a * a + b * b)
    if a + b + c == 1000 then
      print(a * b * c)
      return
    end
  end
end