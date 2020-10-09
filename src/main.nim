import sequtils, sugar, tables, strformat

type
    Variable[T] = ref object of RootObj
        key: string
        domain: seq[T]
proc `$`*(v: Variable): string = &"{{key: \"{v.key}\", domain: {v.domain}}}"

type
    Constraint[T] = ref object of RootObj
        variables: seq[Variable[T]]
        isSatisfied: varargs[T] -> bool

var variables = {
    "a": Variable[int](key: "a", domain: toSeq(1..3)),
    "b": Variable[int](key: "b", domain: toSeq(1..3)),
    "c": Variable[int](key: "c", domain: toSeq(1..3)),
}.toTable;

var constraints = @[
    Constraint[int](
        variables: @[variables["a"], variables["b"]],
        isSatisfied: (v: varargs[int]) => v[0] > v[1]
    ),
]

proc solve[T](variables: Table[string, Variable[T]], constraints: seq[Constraint[T]]): bool =
    false

var result = solve[int](variables, constraints)
echo result