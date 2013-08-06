# Knapsack problem with GA

----------

## Problem setting

Write a Genetic Algorithm to solve the following modified version of the “Knapsack” Problem.

### The Menu Problem
There is a menu with many items. Each item has a money cost (price) and a time cost (delay). You have a fixed amount of money (resource). Find a combination of items from the menu where the price fits your money as closely as possible. (For example, if you have 1500 yens, you have to find a menu combination that gets as close to 1500 yens as possible, without going over). If two combinations have the same price, you want to choose the combination with the lowest time.

### “Simple” and “Advanced” versions
- “Simple” version: in the solution, each item in the menu can only be selected once.
- “Advanced” version: in the solution, each item in the menu can be used as many times as necessary.

### Data Set
The data will be in a file, with the following format. 

    <Total money you own - integer>
    <item 1 name>,<item 1 price>,<item 1 time>
    <item 2 name>,<item 2 price>,<item 2 time>
    ...
    <item N name>,<item N price>,<item N time>
    <END OF FILE>
## Comment

### Implementation

#### Language
I choose Lua because has it's very lightweight and fast to develop with. For the graphics I used LÖVE, which is a library made for games mainly, but offers basic operations like drawing lines, rectangles and text. The main data structure of Lua are tables, which can be used as normal arrays or associative arrays (the index and the value of each entry can be anything, including tables and functions).

#### Implementation
I decided to avoid using external libraries and implement the algorithm in its entirety from scratch so I could have a better understanding of these kind of systems. The algorithm is all contained inside `ga.lua`, while the rest of the files are for the rendering of the graph or to import the dataset and so on, so I'll focus on that. Both the simple and advanced versions are included.

The dataset when parsed is stored as a table of items, where each item has its own cost and time. The initial budget and the size are also saved.

Genomes are simple tables containing ones and zeroes, and the population is represented as a table of genomes. In addition, each genome table has a fitness field, which in turn contains two values, one for the cost and one for the time. Depending on the version of the algorithm, a different bit representation is used. For the simple version, the genome is a table of bits where each bit is `1` if the corresponding (same index) item is selected, and the length is the same as the one of the dataset. For the advanced version things are a bit more complicated. The genome encodes a list of pairs in the form of `<item_id, quantity>`. We first choose the maximum number of different items we can pick for a solution, let us call it `max_item_count` as in the code. For `item_id` we take the ceiling of the logarithm (`clog2()`) of the dataset size (so for example, to encode 2000 possible items 11 bits are required). For the quantity, to avoid imposing arbitrary limitations we first find the cheapest item of the menu and divide the budget by this value. As this is the greatest value that could appear in a solution, we reserve a number of bits for this value as we did for the item id. This number of bits can be overridden though by the `size_bits` parameter, which if set fixes the number of bits for the quantity to a predefined number. The final genome length for the advanced version of problem is then `clog2(max_item_count)・( clog2(item_id) + clog2(quantity) )`.  In this version many solutions could be faulted, for example out-of-range IDs or multiple IDs in the same solution. That's why a checking function is there to discard them.

The initial population is generated randomly, but there are a few special measures have been taken. In the simple version of the problem we can specify the maximum number of `1` present in the genome, to prevent having too many invalid solutions. There is also a flag called `valid_initial_population`, that allows only individuals with fitness greater than `0` when generating the initial population.

The selection phase features tournament selection. Following, crossover and mutation are applied.

In tournament selection the best N individuals are chosen randomly. The best individual among the chosen ones is selected with probability `p` (selection pressure). If it's not, then the second best individual is selected with probability `p(1-p)` and so on.

The crossover is implemented as a one-point crossover, and  has a certain probability of happening each time. The cutting point is chosen randomly.

Mutations too can happen with a certain probability. When they do, each bit of the genome has a chance of changing.

The evaluation functions too is depending on the version of the problem. For the simple one, we iterate through the genome and if a bit is set to `1` we find the corresponding item and accumulate its cost and time. In the advanced one we first decode the bits to obtain `<id, quantity>` pairs, then lookup the item, find the cost and time, multiply them by the quantity and accumulate the values as before.

When fitness values are compared, first the cost is evaluated, and if it's the same then time too is considered. In the case the total cost exceeds the budget there are two options, setting the fitness to `0` or setting it to a negative value proportional to the excess (the `allow_negative_fitness` flag).

When the GA is instantiated, the version (`"a"` for advanced or `"s"` for simple) and a table of parameters are passed as arguments. The options are

- Population size
- Mutation chance
- Bit mutation chance
- Maximum item count
- Elitism
- Tournament size
- Tournament winning chance
- Crossover chance
- Allow negative fitness
- Valid initial population
- Maximum initial ones
- Size bits

Instead of specifying the parameters manually some presets are available in `presets.lua`.

### Results

The algorithm usually finds a solution very quickly and very abruptly, similar to a percolation phenomenon where when a critical value is reached the system explodes (not literally). The optimum cost (consuming all the budget) is not always reached (at least in a short time), and sometimes it takes many generations to lower the time factor (usually raises again when the cost gets better).

In the advanced version, having a fixed maximum number of different items in a solution might feel limiting, but in an optimal solution usually only a few "best" items appear, especially in a problem underconstrained as this (because you can take infinitely many of any item).

While the simple version slows down and becomes unmanageable for big datasets, the advanced version could take a 1.000.000 items problem and solve it. In a dataset so big, the search space is also incredibly large and a genome in the simple version would take 1.000.000 bits, while in the advanced one it takes only 200~300 bits.

The initial budget has a great impacts on algorithm because if we have a search space so vast, and a budget relatively small (like 1.000 or 10.000) the valid solutions are only an insignificant part of it. This also can issue problems when generating the initial population, because most of the solutions will be very bad.

To be able to manage a dataset of around 100.000 items with the simple version, we can use the `max_ones` option. Setting a maximum  number of `1` guarantees that many solutions with a cost clearly too high are not generated (at least initially). Then, reducing the population to only ~10, the algorithm could run at a decent speed and eventually get very close to the best solution.

The option to allow only individuals with a positive fitness did more bad than good. The generation of the initial population takes a lot of time (especially with low budget and many items), and the individuals do not improve much more than usual. After waiting for the population to be completed the best individual has already a very high fitness value, but it takes a really long time. In this case, the algorithm behaves more like a random search.

## Project

### Files

- `conf.lua`
- `main.lua` (Here you can set the algorithm parameters)
- `ga.lua` (The algorithm)
- `dataset.lua`
- `graph.lua`
- `menu.lua`
- `presets.lua` (Here you can define your parameter presets)
- `generate.lua` (Dataset generator)

### Requirements
- [Lua](http://www.lua.org/) to execute the generator.
 - [Binaries only](http://luabinaries.sourceforge.net/)
 - [Lua for Windows](https://code.google.com/p/luaforwindows/)
 - Ubuntu: any package of Lua version 5.1 or greater.
- [LÖVE](http://love2d.org/)

### Usage

#### Generate the dataset
  
`lua` `generate.lua` `<output file>` `<initial budget>` `<number of items>`

Example:
> `lua ks/generate.lua dataset.txt 10000 1024`

Notes:  
The cost and time ranges can be edited inside the script file. The current ranges are [100,1000] for the cost and [0,60] for the time.  
The time is random, but is adjusted to be influenced by the cost, so that something that costs much is likely to have a higher time.

#### Run the program  
`love` `<path to app directory>` `<path to dataset>`

Example:
> `love Desktop/ks Desktop/dataset.txt` 

Notes:  
The first argument is the directory containing the files, not the main itself.  
The Lua executable might be called lua, lua51 or lua52 depending on the source.
