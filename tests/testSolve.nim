import solver, unittest, sequtils, sugar, tables, getSudoku, times, constraint, csp, options

suite "solve csp test":
    # "suite setup: run once before the test"

    setup:
        discard

    test "solve simple":
        var variables = {
            "a": toSeq(1..3),
            "b": toSeq(1..3),
            "c": toSeq(1..3),
        }.newTable

        var constraints = @[
            Constraint[int](
                variables: @["a", "b"],
                isSatisfied: (v: varargs[int]) => v[0] > v[1]
            ),
        ]
        # give up and stop if this fails
        var result = solve(variables, constraints)
        check(result.isSome)

    test "solve sudoku":
        var csp = getSudoku()
        let now = cpuTime()
        var result = solve(csp.variables, csp.constraints)
        var timeTaken = cpuTime() - now
        echo "result = ", result
        echo "time taken: ", timeTaken * 1000 ," ms"
        check(result.isSome)
