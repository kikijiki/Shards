local M = {}
M.__index = M

function M:new(mode, parameters, dataset)
  ga = {
    population = {},
    ready = false,
    dataset = dataset,
    mode = mode
  }
  
  for i,v in pairs(parameters) do ga[i] = v end
  
  if not ga.dataset then 
    love.event.push("quit") 
    return
  end
  
  -- Since Love2D does not use Lua 5.2, only the natural and base-10 log are defined.
  local clog2 = function(x) return math.ceil(math.log(x) / math.log(2)) end
  
  if mode == "a" then
    -- Advanced version.
    ga.evaluate = self.evaluateA
    ga.format = self.formatA
    
    if not ga.size_bits then
      -- If they are not specified, find the bits required to store the maximum count of an item.
      -- This is equal to the budget divided by the cheapest item in the menu (rounded up).
      local cheapest = ga.dataset.items[1].cost
      for _,v in pairs(ga.dataset.items) do cheapest = math.min(cheapest, v.cost) end
      ga.size_bits = clog2(ga.dataset.budget / cheapest)
    end

    ga.id_bits = clog2(ga.dataset.size) -- Bits required to store the item index.
    ga.gene_size = (ga.size_bits + ga.id_bits) * ga.max_item_count -- Total length of the genome.
    
    ga.info = 
        "Advanced version"..
      "\nUsing a genome length of "..ga.gene_size.."bits."..
      "\nItem quantity encoding: "..ga.size_bits..
      "\nItem ID encoding: "..ga.id_bits.." ("..ga.dataset.size.." elements)"..
      "\nMaximum different items: "..ga.max_item_count    
  else
    -- Simple version.
    
    ga.evaluate = self.evaluateS
    ga.format = self.formatS
    ga.gene_size = ga.dataset.size -- In the simple version each bit represents if we take the item at that index.
    
    ga.info = 
        "Simple version"..
      "\nUsing a genome length of "..ga.gene_size.."bits."
  end
  
  ga.parameters = 
      "Parameters"..
    "\nPopulation size: "..ga.population_size..
    "\nElitism: "..(ga.elitism)..
    "\nMutation chance: "..ga.mutation_chance..
    "\nMaximum number different items: "..ga.max_item_count..
    "\nTournament size: "..ga.tournament_size..
    "\nTournament winning chance (max): "..ga.tournament_winning_chance..
    "\nCrossover chance: "..ga.crossover_chance..
    "\nAllow neg. fitness: "..tostring(ga.allow_negative_fitness)..
    "\n\nDataset"..
    "\nBudget: "..ga.dataset.budget..
    "\nItems: "..ga.dataset.size

  math.randomseed(os.time())
  return setmetatable(ga, self)
end

-- Convert a part of the genome to an integer.
function getInt(g, start, bits)
  local value = 0
  local p = bits - 1
  
  for i = start, start + bits - 1 do
    value = value + g[i] * 2^p
    p = p - 1
  end
  
  return value, start + bits
end

-- Evaluation function (simple version).
function M:evaluateS(g)
  local fitness = {cost = 0, time = 0}
  
  -- Sum all the items costs and times.
  for i = 1, #g do
    if g[i] == 1 then 
      local item = self.dataset.items[i]
      fitness.cost = fitness.cost + item.cost
      fitness.time = fitness.time + item.time
    end
  end
  
  -- If the total exceeds the budget, set the fitness to 0, or to a negative value.
  if fitness.cost > self.dataset.budget then 
    if self.allow_negative_fitness then
      fitness.cost = self.dataset.budget - fitness.cost
    else fitness.cost = 0 end
  end
  
  return fitness
end

-- Evaluation function (advanced version version).
function M:evaluateA(g)
  local start = 1
  local fitness = {cost = 0, time = 0}
  local data = self:getData(g) -- Parse the genome.
  local items = self.dataset.items
  local ids = {}
  
  for _,v in pairs(data) do
    if v.id > self.dataset.size or v.id < 1 then return nil end -- Discard invalid IDs.
    
    if ids[v.id] then return nil end -- Discard genomes with duplicates.
    ids[v.id] = true
    
    -- Update the fitness value.
    local cost = items[v.id].cost
    local time = items[v.id].time
    fitness.cost = fitness.cost + v.count * cost
    fitness.time = fitness.time + v.count * time
  end
  
  -- If the total exceeds the budget, set the fitness to 0, or to a negative value.
  if fitness.cost > self.dataset.budget then 
    if self.allow_negative_fitness then
      fitness.cost = self.dataset.budget - fitness.cost
    else fitness.cost = 0 end
  end
  
  return fitness  
end

-- Parse the bit string and return the list of items (pairs of id and quantity). 
-- (for the advanced version)
function M:getData(g)
  local start = 1
  local id, count
  local data = {}
  for i = 1, self.max_item_count do
    id, start = getInt(g, start, self.id_bits)
    count, start = getInt(g, start, self.size_bits)
    table.insert(data, {id = id, count = count})
  end
  return data
end

-- Add a random individual to the population.
function M:populate()
  local pop = self.population
  
  -- When we reach the desired population size, sort the population and set the ready flag to true.
  if #pop == self.population_size then
    self:sort(pop)
    self.ready = true
  end
  
  local individual = self:makeRandomIndividual()
  table.insert(pop, individual)
end

-- Create a random individual.
function M:makeRandomIndividual()
  while true do
    local g = {}
    
    -- If set, use at most max_initial_ones "1" bits. 
    -- (mainly for the simple version)
    if self.max_initial_ones then
      local ones = {
        count = math.random(1, self.max_initial_ones),
        indices = {}}
        
      for i = 1, self.gene_size do g[i] = 0 end
      
      for i = 1, ones.count do
        local id = math.random(self.gene_size)
        g[id] = 1
      end
    else
      for i = 1, self.gene_size do
        table.insert(g, math.random(2) - 1)
      end    
    end
    
    g.fitness = self:evaluate(g)
    
    -- Return this individual if it passes the check. If not, try again.
    if self:check(g, self.valid_initial_population) then return g end
  end
end

-- Sort the population by fitness (descending, first by priority then by time).
function M:sort(pop)
  table.sort(
    pop, 
    function(a, b)
      if a.fitness.cost == b.fitness.cost then
        return a.fitness.time > b.fitness.time -- "<" if time is not inverted
      else
        return a.fitness.cost > b.fitness.cost
      end
    end)
end

-- Tournament selection.
function M:tournament(pop, size)
  local candidates = {}
  for i = 1, size do
    --local candidate = table.remove(pop, math.random(1, #pop))
    local c = pop[math.random(1, #pop)]
    table.insert(candidates, c)
  end
  
  self:sort(candidates)
  
  -- The best individual among the selected ones has a probability of "p" of being chosen.
  -- If not, the next one has a probability of P * (1-p) and so on.
  local p = self.tournament_winning_chance
  for _,v in pairs(candidates) do
    if math.random() < p then return self:clone(v) end
    p = p * (1 - p)
  end
  
  -- If none has been selected, take the best.
  return self:clone(candidates[1])
end

-- Check if a genome is acceptable.
function M:check(g, strict)
  -- "nil" fitness, means the id was invalid or there were duplicates. (advanced version)
  if not g.fitness then return false end
  -- If the strict flag is on, accept only positive fitness costs.
  if strict and g.fitness.cost <= 0 then return false end
  return true
end

-- Copy a genome (deep copy).
function M:clone(g)
  local c = {}
  for i = 0, #g do c[i] = g[i] end
  c.fitness = {
    cost = g.fitness.cost,
    time = g.fitness.time}
  return c
end

-- An iteration of the genetic algorithm.
function M:step()
  local pop = self.population
  local pool = {}

  -- Copy the "N" best individuals if elitism is on.
  if self.elitism and type(self.elitism) == "number" then
    for i = 1, self.elitism do table.insert(pool, self:clone(pop[i])) end
  end
  
  -- Keep generating new individuals until we have the desired population.
  while #pool < self.population_size do
    local p1 = self:tournament(pop, self.tournament_size)
    local p2 = self:tournament(pop, self.tournament_size)

    -- If crossovering happens, compute the new genomes.
    -- Then, try to mutate -> evaluate -> check -> add to the new population. 
    if math.random() < self.crossover_chance then
      local c1, c2 = self:crossover(p1, p2)
      self:mutateAndEvaluate(c1) self:checkAdd(c1, pool)
      self:mutateAndEvaluate(c2) self:checkAdd(c2, pool)
    else
      self:mutateAndEvaluate(p1) self:checkAdd(p1, pool)
      self:mutateAndEvaluate(p2) self:checkAdd(p2, pool)
    end
  end
  
  self:sort(pool)
  self.population = pool
end

-- Add an individual only if passes the check.
function M:checkAdd(g, pool)
  if self:check(g) then table.insert(pool, g) end
end

-- First try to mutate, then re-evaluate.
function M:mutateAndEvaluate(g)
  self:mutate(g)
  g.fitness = self:evaluate(g)
end

-- Possibly cause a mutation
function M:mutate(g)
  if math.random() < self.mutation_chance then
    for i = 1, self.gene_size do
      if math.random() < self.bit_mutation_chance then
        g[i] = 1 - g[i] -- Invert.
      end
    end
  end
end

-- Mix two genomes
function M:crossover(g1, g2)
  local cut = math.random(1, self.gene_size) -- Cut randomly.
  local g3, g4 = {}, {}
  
  -- The first 1,2,..cut bits of g1 and g2 are copied respectively to g3 and g4.
  for i = 1, cut do
    table.insert(g3, g1[i])
    table.insert(g4, g2[i])
  end
  
  -- The remaining cut+1,cut+2..size bits of g1 and g2 are copied respectively to g4 and g3 (inverted).
  for i = cut + 1, self.gene_size do
    table.insert(g3, g2[i])
    table.insert(g4, g1[i])
  end
  
  g3.fitness = self:evaluate(g3)
  g4.fitness = self:evaluate(g4)
  
  return g3, g4
end

-- Pretty print of a genome.
function M:formatGenome(g)
  local genome = {}
  local gen_line = 80
  local max_lines = 4
  local line_count = 0
  local j = 0
  
  for i = 1, #g do
    table.insert(genome, g[i])
    if math.mod(i, gen_line) == 0 then
      if line_count > max_lines then
        table.insert(genome, "...")
        break
      else
        table.insert(genome, "\n")
        line_count = line_count + 1
      end
    end
  end
  
  return table.concat(genome)
end

-- Pretty print of an individual (advanced version).
function M:formatA(g)
  local buf = {}
  local items = self.dataset.items
  local genome = self:formatGenome(g)
  table.insert(buf, "Genome:\n"..genome.."\n")
  table.insert(buf, "Fitness:cost->"..g.fitness.cost..", time->"..g.fitness.time.."\n")
  table.insert(buf, "Content:")

  local data = self:getData(g)
  for _,v in pairs(data) do
    if v.count > 0 then    
      table.insert(buf, "\n- "..items[v.id].name.." x"..v.count)
    end
  end
  
  return table.concat(buf)
end

-- Pretty print of an individual (simple version).
function M:formatS(g)
  local buf = {}
  local itemlist = {}
  local items = self.dataset.items
  local genome = self:formatGenome(g)
  table.insert(buf, "Genome:\n"..genome.."\n")
  table.insert(buf, "Fitness:cost->"..g.fitness.cost..", time->"..g.fitness.time.."\n")
  table.insert(buf, "Content:")
  for i = 1, #g do
    if g[i] == 1 then table.insert(itemlist, items[i].name) end
  end
  table.insert(buf, table.concat(itemlist, ", "))
  
  return table.concat(buf)
end

-- Get the best individual from the population.
function M:getBest()
  return self.population[1]
end

-- Compute the best and average fitness for the actual population.
function M:getFitnessStats()
  local best_cost = self:getBest().fitness.cost
  local best_time = self:getBest().fitness.time
  local average_cost = 0
  local average_time = 0
  
  for _,v in pairs(self.population) do
    average_cost = average_cost + v.fitness.cost
    average_time = average_time + v.fitness.time
  end
  
  average_cost = average_cost / #self.population
  average_time = average_time / #self.population
  
  return best_cost, best_time, average_cost, average_time
end

return M