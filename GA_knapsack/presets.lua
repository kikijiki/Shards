local M = {}

M.preset1 = {
  population_size = 100,
  mutation_chance = 0.5,
  bit_mutation_chance = 0.1,
  max_item_count = 10,
  elitism = 1,
  tournament_size = 2,
  tournament_winning_chance = 0.75,
  crossover_chance = 0.5,
  allow_negative_fitness = true,
  valid_initial_population = false,
  size_bits = nil,
  max_initial_ones = false
}

-- Strict parameters to allow a good initial population and
-- always have good individuals throughout the execution.
M.preset2 = {
  population_size = 100,
  mutation_chance = 0.5,
  bit_mutation_chance = 0.1,
  max_item_count = 10,
  elitism = 1,
  tournament_size = 2,
  tournament_winning_chance = 0.75,
  crossover_chance = 0.5,
  allow_negative_fitness = false,
  valid_initial_population = true,
  size_bits = nil,
  max_initial_ones = false
}

-- Preset to allow the simple version to tackle 100.000 items.
M.preset3 = {
  population_size = 10,
  mutation_chance = 0.5,
  bit_mutation_chance = 0.1,
  max_item_count = 10,
  elitism = 1,
  tournament_size = 2,
  tournament_winning_chance = 0.75,
  crossover_chance = 0.5,
  allow_negative_fitness = false,
  valid_initial_population = false,
  max_initial_ones = 10,
}

return M