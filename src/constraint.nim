import sugar, strformat

type
    Constraint*[T] = ref object of RootObj
        variables*: seq[string]
        isSatisfied*: varargs[T] -> bool

proc `$`*(v: Constraint): string = &"Constraint: {v.variables}"

proc allDifferent*[T](variables: seq[string], t: T): seq[Constraint[T]] =
    proc notEqual(v: varargs[T]): bool = v[0] != v[1]
    for variable in variables:
        for otherVariable in variables:
            if variable == otherVariable:
                continue
            result.add Constraint[T](variables: @[variable, otherVariable], isSatisfied: notEqual)