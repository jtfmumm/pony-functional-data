use "ponytest"
use "collections"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestMap)
    test(_TestFlatMap)
    test(_TestFlatten)
    test(_TestFilter)
    test(_TestFold)
    test(_TestEvery)
    test(_TestExists)
    test(_TestPartition)
    test(_TestDrop)

class iso _TestMap is UnitTest
  fun name(): String => "map()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2)

    let f = lambda(a: U32): U32 => consume a * 2 end
    let c = ListT.map[U32,U32](a, f)

    h.expect_eq[U32](c(0), 0)
    h.expect_eq[U32](c(1), 2)
    h.expect_eq[U32](c(2), 4)

    true

class iso _TestFlatMap is UnitTest
  fun name(): String => "flatMap()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2)

    let f = lambda(a: U32): List[U32] => List[U32].push(consume a * 2) end
    let c = ListT.flatMap[U32,U32](a, f)

    h.expect_eq[U32](c(0), 0)
    h.expect_eq[U32](c(1), 2)
    h.expect_eq[U32](c(2), 4)

    true

class iso _TestFlatten is UnitTest
  fun name(): String => "flatten()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[List[U32]]
    let l1 = List[U32].push(0).push(1)
    let l2 = List[U32].push(2).push(3)
    let l3 = List[U32].push(4)
    a.push(l1).push(l2).push(l3)

    let b: List[U32] = ListT.flatten[U32](a)

    h.expect_eq[U32](b(0), 0)
    h.expect_eq[U32](b(1), 1)
    h.expect_eq[U32](b(2), 2)
    h.expect_eq[U32](b(3), 3)
    h.expect_eq[U32](b(4), 4)

    let c = List[List[U32]]
    let d = ListT.flatten[U32](c)
    h.expect_eq[U64](d.size(), 0)

    true

class iso _TestFilter is UnitTest
  fun name(): String => "filter()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let f = lambda(a: U32): Bool => consume a > 1 end
    let b = ListT.filter[U32](a, f)

    h.expect_eq[U64](b.size(), 2)
    h.expect_eq[U32](b(0), 2)
    h.expect_eq[U32](b(1), 3)

    true

class iso _TestFold is UnitTest
  fun name(): String => "fold()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let f = lambda(acc: U32, x: U32): U32 => acc + x end
    let value = ListT.fold[U32,U32](a, f, 0)

    h.expect_eq[U32](value, 6)

    let g = lambda(acc: List[U32], x: U32): List[U32] => acc.push(x * 2) end
    let resList = ListT.fold[U32,List[U32]](a, g, List[U32])

    try h.expect_eq[U32](resList(0), 0) else error end
    try h.expect_eq[U32](resList(1), 2) else error end
    try h.expect_eq[U32](resList(2), 4) else error end
    try h.expect_eq[U32](resList(3), 6) else error end

    true

class iso _TestEvery is UnitTest
  fun name(): String => "every()"

  fun apply(h: TestHelper): TestResult =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let f = lambda(x: U32): Bool => x < 4 end
    let g = lambda(x: U32): Bool => x < 3 end
    let z = lambda(x: U32): Bool => x < 0 end
    let lessThan4 = ListT.every[U32](a, f)
    let lessThan3 = ListT.every[U32](a, g)
    let lessThan0 = ListT.every[U32](a, z)

    h.expect_eq[Bool](lessThan4, true)
    h.expect_eq[Bool](lessThan3, false)
    h.expect_eq[Bool](lessThan0, false)

    let b = List[U32]
    let empty = ListT.every[U32](b, f)
    h.expect_eq[Bool](empty, true)

    true

class iso _TestExists is UnitTest
  fun name(): String => "exists()"

  fun apply(h: TestHelper): TestResult =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let f = lambda(x: U32): Bool => x > 2 end
    let g = lambda(x: U32): Bool => x >= 0 end
    let z = lambda(x: U32): Bool => x < 0 end
    let gt2 = ListT.exists[U32](a, f)
    let gte0 = ListT.exists[U32](a, g)
    let lt0 = ListT.exists[U32](a, z)

    h.expect_eq[Bool](gt2, true)
    h.expect_eq[Bool](gte0, true)
    h.expect_eq[Bool](lt0, false)

    let b = List[U32]
    let empty = ListT.exists[U32](b, f)
    h.expect_eq[Bool](empty, false)

    true

class iso _TestPartition is UnitTest
  fun name(): String => "partition()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let isEven = lambda(x: U32): Bool => x % 2 == 0 end
    (let evens, let odds) = ListT.partition[U32](a, isEven)

    try h.expect_eq[U32](evens(0), 0) else error end
    try h.expect_eq[U32](evens(1), 2) else error end
    try h.expect_eq[U32](odds(0), 1) else error end
    try h.expect_eq[U32](odds(1), 3) else error end

    let b = List[U32]
    (let emptyEvens, let emptyOdds) = ListT.partition[U32](b, isEven)

    h.expect_eq[U64](emptyEvens.size(), 0)
    h.expect_eq[U64](emptyOdds.size(), 0)

    true


class iso _TestDrop is UnitTest
  fun name(): String => "drop()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let isEven = lambda(x: U32): Bool => x % 2 == 0 end
    (let evens, let odds) = ListT.partition[U32](a, isEven)

    try h.expect_eq[U32](evens(0), 0) else error end
    try h.expect_eq[U32](evens(1), 2) else error end
    try h.expect_eq[U32](odds(0), 1) else error end
    try h.expect_eq[U32](odds(1), 3) else error end

    let b = List[U32]
    (let emptyEvens, let emptyOdds) = ListT.partition[U32](b, isEven)

    h.expect_eq[U64](emptyEvens.size(), 0)
    h.expect_eq[U64](emptyOdds.size(), 0)

    true