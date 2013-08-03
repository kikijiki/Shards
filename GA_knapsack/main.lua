local g = love.graphics
local fs = love.filesystem

local Dataset = require "dataset"
local Menu = require "menu"
local GA = require "ga"
local Graph = require "graph"
local Presets = require "presets"

local ga
local menu
local graph

local first_frame = true
local population_speed = 1
local dataset_path

local version = "a"
local parameters = {
  -- The initial population size (maintained more or less).
  population_size = 100,
  -- 
  mutation_chance = 0.5,
  --
  bit_mutation_chance = 0.1,
  -- In the advanced version, the maximum number of different items.
  max_item_count = 10,
  -- The first best N individuals to keep, or false.    
  elitism = 1,
  --
  tournament_size = 2,
  -- Probability for the first position. Scales down as p = p(1-p) at each subsequent position.
  tournament_winning_chance = 0.75, 
  --
  crossover_chance = 0.5,
  --[[ If false, combinations that doesn't fit in the budget are given a fitness of 0.
       If true instead they become negative (fitness = budget - total_cost).]]
  allow_negative_fitness = true,
  -- If true, individuals with 0 or lower fitness are discarded.
  valid_initial_population = false, 
  -- When populating, the maximum number of "1" bits in the genome (to use with the simple version). Or false.
  max_initial_ones = false, 
  --[[In the advanced version, the number of bits to store the multiplicity of an item is 
      computed as the log2 of the budget divided by the cheapest item cost.
      If size_bits is set though, this value will be used instead.]]
  size_bits = false
}

-- There are also some presets defined. To add more presets, edit presets.lua
-- Uncomment the following line to use presets.
-- parameters = Presets.preset1

function love.load(args)
  dataset_path = args
end

function love.keypressed(key)
   if key == "escape" then love.event.push("quit") end
end

function love.update()
  --Let me draw the first frame before starting.
  if first_frame then first_frame = false return end
  
  if not ga then
    ga = GA:new(version, parameters, Dataset.open(dataset_path))
  
    if ga then
      menu = Menu:new(ga.dataset.items)
      graph = Graph:new(600, 400, ga.dataset.budget, 2000)
    end
    return
  end
  
  if ga.ready then ga:step()
  else
    for i = 1, population_speed do ga:populate() end
  end
end

function love.draw()
  if not ga then
    g.print("Loading dataset...", 400, 400)
    return
  end
  
  menu:draw(2, 2, ga.dataset)
  
  if ga.ready then
    graph:append(ga:getFitnessStats())
    graph:draw(300, 50)
    
    g.setColor(255, 255, 255)
    g.printf(ga.info, 10, 500, 300, "left")
    g.printf(ga.parameters, 10, 600, 300, "left")
    g.printf("Best individual\n"..ga:format(ga:getBest()), 300, 500, 650, "left")
  else
    local progress = #ga.population / ga.population_size
    g.print("Populating...("..tostring(progress * 100).."%)", 400, 400)
  end
end