import sequtils, sugar, tables, strformat, options

type
    Constraint*[T] = ref object of RootObj
        variables*: seq[string]
        isSatisfied*: varargs[T] -> bool
proc `$`*(v: Constraint): string = &"{{Constraint: \"{v.variables}\"}}"

proc allDifferent*[T](variables: seq[string], t: T): seq[Constraint[T]] =
    proc notEqual(v: varargs[T]): bool = v[0] != v[1]
    for variable in variables:
        for otherVariable in variables:
            if variable == otherVariable:
                continue
            result.add Constraint[T](variables: @[variable, otherVariable], isSatisfied: notEqual)

proc partialAssignment[T](assigned: TableRef[string, seq[T]], unassigned: TableRef[string, seq[T]]):
    TableRef[string, seq[T]] =
    var result = newTable[string, seq[T]]()
    for key, value in assigned:
        result[key] = value
    for key, value in unassigned:
        result[key] = value
    return result


proc enforceConsistency[T](
        assigned: TableRef[string, seq[T]],
        unassigned: TableRef[string, seq[T]],
        constraints: seq[Constraint[T]]
    ): Option[TableRef[string, seq[T]]] =
    proc removeInconsistentValues(head: string, tail: string, constraint: Constraint[T], variables: TableRef[string, seq[T]]): bool =
        var headValues = variables[head]
        var tailValues = variables[tail]
        var validTailValues = tailValues.filter((t) => headValues.any((h) => constraint.isSatisfied(h, t)))
        var removed = tailValues.len != validTailValues.len
        variables[tail] = validTailValues
        return removed

    var binaryConstraints = constraints.filter((x) => x.variables.len == 2)

    proc incomingConstraints(nodeKey: string): seq[Constraint[T]] =
        binaryConstraints.filter((x) => x.variables[0] == nodeKey)

    var variables = partialAssignment(assigned, unassigned)
    # makes copy of sequence:
    var queue = binaryConstraints

    for constraint in constraints.filter((c) => c.variables.len == 1):
        var varKey  = constraint.variables[0]
        variables[varKey] = variables[varKey].filter((v) => constraint.isSatisfied(v))
        if variables[varKey].len == 0:
            return none(TableRef[string, seq[T]])

    while queue.len > 0:
        var constraint = queue.pop()
        var head = constraint.variables[0]
        var tail = constraint.variables[1]
        if removeInconsistentValues(head, tail, constraint, variables):
            if variables[tail].len == 0:
                return none(TableRef[string, seq[T]])
            queue = queue.concat(incomingConstraints(tail))

    return some(variables)


proc backtrack[T](
        assigned: TableRef[string, seq[T]],
        unassigned: TableRef[string, seq[T]],
        constraints: seq[Constraint[T]]
    ): bool =
        if unassigned.len == 0:
            echo assigned
            return true

        var (nextKey, values) = toSeq(unassigned.pairs)[0]
        unassigned.del(nextKey)

        for value in values:
            assigned[nextKey] = @[value]
            var consistentResult = enforceConsistency[T](assigned, unassigned, constraints)
            if consistentResult.isNone:
                continue
            var consistent = consistentResult.get()
            var newUnassigned = newTable[string, seq[T]]()
            var newAssigned = newTable[string, seq[T]]()
            for key, value in consistent:
                if key in assigned:
                    newAssigned[key] = assigned[key]
                else:
                    newUnassigned[key] = consistent[key]

            var result = backtrack(newAssigned, newUnassigned, constraints)
            if result != false:
                return result

        return false

proc solve*[T](variables: TableRef[string, seq[T]], constraints: seq[Constraint[T]]): bool =
    var assigned = newTable[string, seq[T]]()
    backtrack(assigned, variables, constraints)