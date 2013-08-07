# NM puzzle

----------

## Implementation
This is a straightforward implementation of the A* algorithm, and probably very slow. In this version, the size of the puzzle can be set at will. Additional details are explained in the comments together with the source code.

First the initial state is pushed in the fringe (a priority queue ordered by increasing cost).
At each iteration, a state is popped from the top of the fringe and is compared to the goal state. If the states are different, the possible moves (up, down, left, right) are evaluated. For each of the possible end states the cost is computed as the sum of the heuristic function and the number of steps so far. Finally the states are pushed again in the fringe if not already marked as visited. To keep a list of visited states, an associative table of IDs is kept in memory, where the ID is simply a string containing the tile values separated by a hyphen (like `"3-10-2-5"`). The algorithm keeps iterating this way until a solution is found or the fringe is exhausted (meaning a solution didn't exist).

## Results
The algorithm could find the solution of all the problems I tried, but it may take quite a bit of time in some cases. The number of shuffles too influenced very much the time required to find a solution. For 4x3 puzzles, 100 shuffles ranged from 1~5 seconds to 15 minutes. Since this is a very naïve implementation with almost no optimizations, and given the size of the search space the fact that it is slow is not surprising. On the other hand, memory consumption (during my limited tests) was acceptable. On the other hand, the classical 8-puzzle setting with 1000 shuffles is always solved immediately, probably because augmenting one dimention of 1 greatly increases the search space. 

## Requirements

[Lua 5.2](http://www.lua.org/)

- [Binaries only](http://luabinaries.sourceforge.net/) (all distributions)
- [Lua for Windows](https://code.google.com/p/luaforwindows/) (contains also libraries and headers)
- Ubuntu: `sudo apt-get install lua5.2`

## Files
- `puzzle.lua` (the main algorithm)
- `pqueue.lua` (a priority queue implementation)

## Usage

`lua puzzle.lua`

Note: depending on the package, the executable name can be `lua` or `lua52`.

## Settings
At the end of `puzzle.lua`

- Puzzle dimensions
- Initial state (custom or random)
- Goal state (custom or default)
- Heuristic function (manhattan distance or difference)
- Initial shuffling