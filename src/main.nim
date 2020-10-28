import solver, sequtils, sugar, tables, getSudoku, times

var (variables, constraints) = getSudoku()
let now = cpuTime()
var result = solve[int](variables, constraints)
var timeTaken = cpuTime() - now
echo "time taken ", timeTaken * 1000 ," ms"