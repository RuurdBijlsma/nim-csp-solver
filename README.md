# Constraint Satisfaction Problem Solver

## Features
* Maintained arc consistency
* Unary or binary constraint support
* Get one solution


## Usage example
```nim
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

var result = solve(variables, constraints)
echo result
# Echoes: 
# Some({CSP solutions: @[{"b": 1, "c": 1, "a": 2}], steps: 3, solutionCount: 1, mrv: true, lcv: false })
```


### Run tests
`nimble test`