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
//    test(_TestDropWhile)
    test(_TestTake)
    test(_TestTakeWhile)

class iso _TestMap is UnitTest
  fun name(): String => "list-transforms/map()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2)

    let f = lambda(a: U32): U32 => consume a * 2 end
    let c = MListT.map[U32,U32](a, f)

    h.expect_eq[U32](c(0), 0)
    h.expect_eq[U32](c(1), 2)
    h.expect_eq[U32](c(2), 4)

    true

class iso _TestFlatMap is UnitTest
  fun name(): String => "list-transforms/flat_map()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2)

    let f = lambda(a: U32): List[U32] => List[U32].push(consume a * 2) end
    let c = MListT.flat_map[U32,U32](a, f)

    h.expect_eq[U32](c(0), 0)
    h.expect_eq[U32](c(1), 2)
    h.expect_eq[U32](c(2), 4)

    true

class iso _TestFlatten is UnitTest
  fun name(): String => "list-transforms/flatten()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[List[U32]]
    let l1 = List[U32].push(0).push(1)
    let l2 = List[U32].push(2).push(3)
    let l3 = List[U32].push(4)
    a.push(l1).push(l2).push(l3)

    let b: List[U32] = MListT.flatten[U32](a)

    h.expect_eq[U32](b(0), 0)
    h.expect_eq[U32](b(1), 1)
    h.expect_eq[U32](b(2), 2)
    h.expect_eq[U32](b(3), 3)
    h.expect_eq[U32](b(4), 4)

    let c = List[List[U32]]
    let d = MListT.flatten[U32](c)
    h.expect_eq[U64](d.size(), 0)

    true

class iso _TestFilter is UnitTest
  fun name(): String => "list-transforms/filter()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let f = lambda(a: U32): Bool => consume a > 1 end
    let b = MListT.filter[U32](a, f)

    h.expect_eq[U64](b.size(), 2)
    h.expect_eq[U32](b(0), 2)
    h.expect_eq[U32](b(1), 3)

    true

class iso _TestFold is UnitTest
  fun name(): String => "list-transforms/fold()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let f = lambda(acc: U32, x: U32): U32 => acc + x end
    let value = MListT.fold[U32,U32](a, f, 0)

    h.expect_eq[U32](value, 6)

    let g = lambda(acc: List[U32], x: U32): List[U32] => acc.push(x * 2) end
    let resList = MListT.fold[U32,List[U32]](a, g, List[U32])

    try h.expect_eq[U32](resList(0), 0) else error end
    try h.expect_eq[U32](resList(1), 2) else error end
    try h.expect_eq[U32](resList(2), 4) else error end
    try h.expect_eq[U32](resList(3), 6) else error end

    true

class iso _TestEvery is UnitTest
  fun name(): String => "list-transforms/every()"

  fun apply(h: TestHelper): TestResult =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let f = lambda(x: U32): Bool => x < 4 end
    let g = lambda(x: U32): Bool => x < 3 end
    let z = lambda(x: U32): Bool => x < 0 end
    let lessThan4 = MListT.every[U32](a, f)
    let lessThan3 = MListT.every[U32](a, g)
    let lessThan0 = MListT.every[U32](a, z)

    h.expect_eq[Bool](lessThan4, true)
    h.expect_eq[Bool](lessThan3, false)
    h.expect_eq[Bool](lessThan0, false)

    let b = List[U32]
    let empty = MListT.every[U32](b, f)
    h.expect_eq[Bool](empty, true)

    true

class iso _TestExists is UnitTest
  fun name(): String => "list-transforms/exists()"

  fun apply(h: TestHelper): TestResult =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let f = lambda(x: U32): Bool => x > 2 end
    let g = lambda(x: U32): Bool => x >= 0 end
    let z = lambda(x: U32): Bool => x < 0 end
    let gt2 = MListT.exists[U32](a, f)
    let gte0 = MListT.exists[U32](a, g)
    let lt0 = MListT.exists[U32](a, z)

    h.expect_eq[Bool](gt2, true)
    h.expect_eq[Bool](gte0, true)
    h.expect_eq[Bool](lt0, false)

    let b = List[U32]
    let empty = MListT.exists[U32](b, f)
    h.expect_eq[Bool](empty, false)

    true

class iso _TestPartition is UnitTest
  fun name(): String => "list-transforms/partition()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3)

    let isEven = lambda(x: U32): Bool => x % 2 == 0 end
    (let evens, let odds) = MListT.partition[U32](a, isEven)

    try h.expect_eq[U32](evens(0), 0) else error end
    try h.expect_eq[U32](evens(1), 2) else error end
    try h.expect_eq[U32](odds(0), 1) else error end
    try h.expect_eq[U32](odds(1), 3) else error end

    let b = List[U32]
    (let emptyEvens, let emptyOdds) = MListT.partition[U32](b, isEven)

    h.expect_eq[U64](emptyEvens.size(), 0)
    h.expect_eq[U64](emptyOdds.size(), 0)

    true

class iso _TestDrop is UnitTest
  fun name(): String => "list-transforms/drop()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3).push(4)

    let b = MListT.drop[U32](a, 2)
    let c = MListT.drop[U32](a, 4)
    let d = MListT.drop[U32](a, 5)
    let e = MListT.drop[U32](a, 6)

    h.expect_eq[U64](b.size(), 3)
    try h.expect_eq[U32](b(0), 2) else error end
    try h.expect_eq[U32](b(2), 4) else error end
    h.expect_eq[U64](c.size(), 1)
    try h.expect_eq[U32](c(0), 4) else error end
    h.expect_eq[U64](d.size(), 0)
    h.expect_eq[U64](e.size(), 0)

    let empty = List[U32]
    let l = MListT.drop[U32](empty, 3)
    h.expect_eq[U64](l.size(), 0)

    true

//class iso _TestDropWhile is UnitTest
//  fun name(): String => "list-transforms/drop_while()"
//
//  fun apply(h: TestHelper): TestResult ? =>
//    let a = List[U32]
//    a.push(0).push(1).push(2).push(3).push(4)
//
//    let f = lambda(x: U32): Bool => x < 5 end
//    let g = lambda(x: U32): Bool => x < 4 end
//    let y = lambda(x: U32): Bool => x < 1 end
//    let z = lambda(x: U32): Bool => x < 0 end
//    let b = MListT.drop_while[U32](a, f)
//    let c = MListT.drop_while[U32](a, g)
//    let d = MListT.drop_while[U32](a, y)
//    let e = MListT.drop_while[U32](a, z)
//
//    h.expect_eq[U64](b.size(), 0)
//    h.expect_eq[U64](c.size(), 1)
//    try h.expect_eq[U32](c(0), 0) else error end
//    h.expect_eq[U64](d.size(), 4)
//    try h.expect_eq[U32](d(0), 1) else error end
//    try h.expect_eq[U32](d(1), 2) else error end
//    try h.expect_eq[U32](d(2), 3) else error end
//    try h.expect_eq[U32](d(3), 4) else error end
//    h.expect_eq[U64](e.size(), 5)
//    try h.expect_eq[U32](e(0), 0) else error end
//    try h.expect_eq[U32](e(1), 1) else error end
//    try h.expect_eq[U32](e(2), 2) else error end
//    try h.expect_eq[U32](e(3), 3) else error end
//    try h.expect_eq[U32](e(4), 4) else error end
//
//    let empty = List[U32]
//    let l = MListT.drop_while[U32](empty, g)
//    h.expect_eq[U64](l.size(), 0)
//
//    true

class iso _TestTake is UnitTest
  fun name(): String => "list-transforms/take()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3).push(4)

    let b = MListT.take[U32](a, 2)
    let c = MListT.take[U32](a, 4)
    let d = MListT.take[U32](a, 5)
    let e = MListT.take[U32](a, 6)
    let m = MListT.take[U32](a, 0)

    h.expect_eq[U64](b.size(), 2)
    try h.expect_eq[U32](b(0), 0) else error end
    try h.expect_eq[U32](b(1), 1) else error end
    h.expect_eq[U64](c.size(), 4)
    try h.expect_eq[U32](c(0), 0) else error end
    try h.expect_eq[U32](c(1), 1) else error end
    try h.expect_eq[U32](c(2), 2) else error end
    try h.expect_eq[U32](c(3), 3) else error end
    h.expect_eq[U64](d.size(), 5)
    try h.expect_eq[U32](d(0), 0) else error end
    try h.expect_eq[U32](d(1), 1) else error end
    try h.expect_eq[U32](d(2), 2) else error end
    try h.expect_eq[U32](d(3), 3) else error end
    try h.expect_eq[U32](d(4), 4) else error end
    h.expect_eq[U64](e.size(), 5)
    try h.expect_eq[U32](e(0), 0) else error end
    try h.expect_eq[U32](e(1), 1) else error end
    try h.expect_eq[U32](e(2), 2) else error end
    try h.expect_eq[U32](e(3), 3) else error end
    try h.expect_eq[U32](e(4), 4) else error end
    h.expect_eq[U64](m.size(), 0)

    let empty = List[U32]
    let l = MListT.take[U32](empty, 3)
    h.expect_eq[U64](l.size(), 0)

    true

class iso _TestTakeWhile is UnitTest
  fun name(): String => "list-transforms/take_while()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = List[U32]
    a.push(0).push(1).push(2).push(3).push(4)

    let f = lambda(x: U32): Bool => x < 5 end
    let g = lambda(x: U32): Bool => x < 4 end
    let y = lambda(x: U32): Bool => x < 1 end
    let z = lambda(x: U32): Bool => x < 0 end
    let b = MListT.take_while[U32](a, f)
    let c = MListT.take_while[U32](a, g)
    let d = MListT.take_while[U32](a, y)
    let e = MListT.take_while[U32](a, z)

    h.expect_eq[U64](b.size(), 5)
    try h.expect_eq[U32](b(0), 0) else error end
    try h.expect_eq[U32](b(1), 1) else error end
    try h.expect_eq[U32](b(2), 2) else error end
    try h.expect_eq[U32](b(3), 3) else error end
    try h.expect_eq[U32](b(4), 4) else error end
    h.expect_eq[U64](c.size(), 4)
    try h.expect_eq[U32](c(0), 0) else error end
    try h.expect_eq[U32](c(1), 1) else error end
    try h.expect_eq[U32](c(2), 2) else error end
    try h.expect_eq[U32](c(3), 3) else error end
    h.expect_eq[U64](d.size(), 1)
    try h.expect_eq[U32](d(0), 0) else error end
    h.expect_eq[U64](e.size(), 0)

    let empty = List[U32]
    let l = MListT.take_while[U32](empty, g)
    h.expect_eq[U64](l.size(), 0)

    true