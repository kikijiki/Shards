local input = 100
local sumsquare = 0
local squaresum = 0

for i=1, input do
  sumsquare = sumsquare + (i * i)
  squaresum = squaresum + i
end

squaresum = squaresum * squaresum

print(squaresum - sumsquare)