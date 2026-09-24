function aoc
    # Inject AoC session cookie from pass store, then delegate to aoc-cli
    set -x ADVENT_OF_CODE_SESSION (pass show web/adventofcode.com/session)
    command aoc $argv
end
