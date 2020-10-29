import sequtils, sugar, tables, options, csp, constraint, algorithm

proc toSolution[T](assigned: TableRef[string, seq[T]]): TableRef[string, T] =
    result = newTable[string, T]()
    for key, value in assigned:
        if value.len > 0:
            result[key] = value[0]

proc partialAssignment[T](assigned: TableRef[string, seq[T]], unassigned: TableRef[string, seq[T]]):
    TableRef[string, seq[T]] =
    result = newTable[string, seq[T]]()
    for key, value in assigned:
        result[key] = value
    for key, value in unassigned:
        result[key] = value

proc enforceConsistency[T](
        assigned: TableRef[string, seq[T]],
        unassigned: TableRef[string, seq[T]],
        constraints: seq[Constraint[T]]
    ): Option[TableRef[string, seq[T]]] =
    proc removeInconsistentValues(constraint: Constraint[T], variables: TableRef[string, seq[T]]): bool =
        let head = constraint.variables[0]
        let tail = constraint.variables[1]
        var headValues = variables[head]
        var tailValues = variables[tail]
        var validTailValues = tailValues.filter((t) => headValues.any((h) => constraint.isSatisfied(h, t)))
        result = tailValues.len != validTailValues.len
        variables[tail] = validTailValues

    var binaryConstraints = constraints.filter((x) => x.variables.len == 2)
    proc incomingConstraints(tailKey: string): seq[Constraint[T]] =
        binaryConstraints.filter((x) => x.variables[0] == tailKey)

    var variables = partialAssignment(assigned, unassigned)
    # makes copy of sequence:
    var queue = binaryConstraints

    # process unary constraints
    for constraint in constraints.filter((c) => c.variables.len == 1):
        let varKey  = constraint.variables[0]
        variables[varKey] = variables[varKey].filter((v) => constraint.isSatisfied(v))
        if variables[varKey].len == 0:
            return none(TableRef[string, seq[T]])

    while queue.len > 0:
        let constraint = queue.pop()
        let tail = constraint.variables[1]
        if removeInconsistentValues(constraint, variables):
            if variables[tail].len == 0:
                return none(TableRef[string, seq[T]])
            queue = queue.concat(incomingConstraints(tail))

    return some(variables)

# LCV: Least constraining value
proc orderValues[T](nextKey: string, assigned: TableRef[string, seq[T]], unassigned: TableRef[string, seq[T]], csp: CSP[T]): auto =
    if not csp.lcv:
        return unassigned[nextKey]

    proc countValues(vars: Option[TableRef[string, seq[T]]]): auto =
        if vars.isNone:
            return 0
        let variables = vars.get()
        var sum = 0
        for key, value in variables:
            sum += value.len
        return sum

    proc valuesEliminated(val: int): auto =
        assigned[nextKey] = @[val]
        let newLength = countValues(enforceConsistency(assigned, unassigned, csp.constraints))
        assigned.del(nextKey)
        return newLength

    let cache = newTable[T, int]()
    var values = unassigned[nextKey]
    for value in values:
        cache[value] = valuesEliminated(value)

    values.sort((a: T, b: T) => cache[b] - cache[a]);
    return values;

# MRV: Minimum Remaining Values
proc selectVariableKey[T](unassigned: TableRef[string, seq[T]], csp: CSP[T]): string =
    if not csp.mrv:
        for key, value in unassigned:
            return key

    var minLen = high(int);
    for key, value in unassigned:
        if value.len < minLen:
            result = key;
            minLen = value.len;

proc backtrack[T](
        assigned: TableRef[string, seq[T]],
        unassigned: TableRef[string, seq[T]],
        csp: CSP[T]
    ): bool =
        if unassigned.len == 0:
            csp.solutions.add toSolution(assigned)
            return true

        var nextKey = selectVariableKey(unassigned, csp)
        var values = orderValues(nextKey, assigned, unassigned, csp)
        unassigned.del(nextKey)

        for value in values:
            assigned[nextKey] = @[value]
            let consistentResult = enforceConsistency[T](assigned, unassigned, csp.constraints)
            if consistentResult.isNone:
                continue
            let consistent = consistentResult.get()
            let newUnassigned = newTable[string, seq[T]]()
            let newAssigned = newTable[string, seq[T]]()

            var emptyFound = false
            for key, value in consistent:
                if value.len == 0:
                    emptyFound = true
                    break

                if key in assigned:
                    newAssigned[key] = assigned[key]
                else:
                    newUnassigned[key] = consistent[key]

            if emptyFound:
                echo "this isn't a valid path"
                continue

            csp.steps += 1

            if backtrack(newAssigned, newUnassigned, csp):
                return true

        return false

proc solve*[T](variables: TableRef[string, seq[T]], constraints: seq[Constraint]): Option[CSP[T]] =
    var assigned = newTable[string, seq[T]]()
    let csp = newCSP[T](variables, constraints)
    discard backtrack(assigned, csp.variables, csp)
    if csp.solutions.len == 0:
        return none(CSP[T])
    some(csp)