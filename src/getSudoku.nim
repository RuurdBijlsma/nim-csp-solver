import solver, sequtils, tables, math, strutils

proc getSudoku*(): (TableRef[string, seq[int]], seq[Constraint[int]])=

    const SIZE = 9
    const BLOCK_SIZE = sqrt(SIZE.float).int
    const domain = 1..9
    let variables = newTable[seq[int], seq[int]]()

    for x in 0..<SIZE:
        for y in 0..<SIZE:
            variables[@[x, y]] = toSeq domain;

    proc getRow(y: int): seq[string] =
        for i in 0..<SIZE:
            result.add @[i, y].join(",")

    proc getColumn(x: int): seq[string] =
        for i in 0..<SIZE:
            result.add @[x, i].join(",")

    proc getBlock(i: int): seq[string] =
        let xOffset = (i mod BLOCK_SIZE) * BLOCK_SIZE
        let yOffset = (i div BLOCK_SIZE) * BLOCK_SIZE
        for x in 0..<BLOCK_SIZE:
            for y in 0..<BLOCK_SIZE:
                result.add @[x + xOffset, y + yOffset].join(",")

    var constraints = newSeq[Constraint[int]]();
    for i in 0..<SIZE:
        constraints = constraints.concat(
            allDifferent(getRow i, 1),
            allDifferent(getColumn i, 1),
            allDifferent(getBlock i, 1),
         )

    let cells2 = {
        @[0, 0]: 1,
        @[3, 1]: 4,
        @[2, 2]: 2,
        @[1, 3]: 3,
    }.toTable

    # Wilco sudoku
    let cells = {
        @[0, 0]: 6,
        @[8, 0]: 5,
        @[1, 1]: 4,
        @[5, 1]: 3,
        @[0, 2]: 2,
        @[1, 2]: 3,
        @[0, 3]: 3,
        @[3, 3]: 1,
        @[6, 3]: 5,
        @[7, 3]: 4,
        @[3, 4]: 3,
        @[4, 4]: 2,
        @[6, 4]: 8,
        @[7, 4]: 7,
        @[5, 5]: 8,
        @[7, 5]: 1,
        @[2, 6]: 1,
        @[5, 6]: 6,
        @[6, 6]: 2,
        @[1, 7]: 6,
        @[2, 7]: 3,
        @[8, 7]: 7,
        @[0, 8]: 9,
        @[3, 8]: 4,
        @[4, 8]: 5,
        @[6, 8]: 6,
        @[8, 8]: 1,
    }.toTable

    for key, value in cells:
        if key in variables:
            variables[key] = @[value]

    let stringVariables = newTable[string, seq[int]]()
    for key, value in variables:
        stringVariables[key.join(",")] = value

    return (stringVariables, constraints)


    #// CSP sudoku
    #// const cells = [
    #//     [[1, 1], 6],
    #//     [[1, 5], 2],
    #//     [[1, 6], 5],
    #//     [[1, 7], 8],
    #//     [[2, 5], 7],
    #//     [[3, 1], 8],
    #//     [[3, 3], 4],
    #//     [[3, 9], 9],
    #//     [[4, 1], 4],
    #//     [[4, 3], 7],
    #//     [[4, 4], 3],
    #//     [[4, 8], 2],
    #//     [[5, 2], 1],
    #//     [[5, 8], 9],
    #//     [[6, 2], 8],
    #//     [[6, 6], 4],
    #//     [[6, 7], 5],
    #//     [[6, 9], 7],
    #//     [[7, 1], 3],
    #//     [[7, 7], 7],
    #//     [[7, 9], 2],
    #//     [[8, 5], 9],
    #//     [[9, 3], 2],
    #//     [[9, 4], 5],
    #//     [[9, 5], 6],
    #//     [[9, 9], 1],
    #// ];