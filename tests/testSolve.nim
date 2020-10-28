import solver, unittest, sequtils, sugar, tables, getSudoku, times

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
        var result = solve[int](variables, constraints)
        echo result
        require(true)

    test "solve sudoku":
        var (variables, constraints) = getSudoku()
        let now = cpuTime()
        var result = solve[int](variables, constraints)
        var timeTaken = cpuTime() - now
        echo "time taken ", timeTaken * 1000 ," ms"
        require(true)



