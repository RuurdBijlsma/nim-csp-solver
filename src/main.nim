import solver, sequtils, sugar, tables, getSudoku, times, options, csp

var sudoku = getSudoku()
let now = cpuTime()
var result = solve(sudoku.variables, sudoku.constraints)
var timeTaken = cpuTime() - now
echo "result = ", result
echo "time taken: ", timeTaken * 1000, " ms"