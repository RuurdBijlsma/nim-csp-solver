import solver, sequtils, sugar, tables, math, strutils

proc getSudoku*(): (TableRef[string, seq[int]], seq[Constraint[int]])=

    const SIZE = 4
    const BLOCK_SIZE = 2
    const domain = 1..4
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
        let xOffset = (i mod BLOCK_SIZE) * BLOCK_SIZE + 1
        let yOffset = (i div BLOCK_SIZE) * BLOCK_SIZE + 1
        for x in 0..<BLOCK_SIZE:
            for y in 0..<BLOCK_SIZE:
                result.add @[x + xOffset, y + yOffset].join(",")

    var constraints = newSeq[Constraint[int]]();
    for i in 0..<SIZE:
        constraints = constraints.concat(allDifferent[int](getRow i, 1), allDifferent(getColumn i, 1))

    let cells = {
        @[0, 0]: 1,
        @[3, 1]: 4,
        @[2, 2]: 2,
        @[1, 3]: 3,
    }.toTable

    for key, value in cells:
        if key in variables:
            variables[key] = @[value]

    let stringVariables = newTable[string, seq[int]]()
    for key, value in variables:
        stringVariables[key.join(",")] = value

    return (stringVariables, constraints)



    #// wilco's sudoku
    #const cells = [
    #    [[1, 1], 6],
    #    [[9, 1], 5],
    #    [[2, 2], 4],
    #    [[6, 2], 3],
    #    [[1, 3], 2],
    #    [[2, 3], 3],
    #   [[1, 4], 3],
    #    [[4, 4], 1],
    #    [[7, 4], 5],
    #    [[8, 4], 4],
    #    [[4, 5], 3],
    #    [[5, 5], 2],
    #    [[7, 5], 8],
    #    [[8, 5], 7],
    #    [[6, 6], 8],
    #    [[8, 6], 1],
    #    [[3, 7], 1],
    #    [[6, 7], 6],
    #    [[7, 7], 2],
    #    [[2, 8], 6],
    #    [[3, 8], 3],
    #    [[9, 8], 7],
    #    [[1, 9], 9],
    #    [[4, 9], 4],
    #    [[5, 9], 5],
    #    [[7, 9], 6],
    #    [[9, 9], 1],
    #];

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