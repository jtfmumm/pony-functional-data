use "ponytest"
use "../function-types"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestPrepend)
    test(_TestFrom)
    test(_TestConcat)
    test(_TestMap)
    test(_TestFlatMap)
    test(_TestFilter)
    test(_TestFold)
    test(_TestEveryExists)
    test(_TestPartition)
    test(_TestDrop)
    test(_TestDropWhile)
    test(_TestTake)
    test(_TestTakeWhile)


class iso _TestPrepend is UnitTest
  fun name(): String => "persistent-data/List/prepend()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = ListT.empty[U32]()
    let b = ListT.cons[U32](1, ListT.empty[U32]())
    let c = ListT.cons[U32](2, b)
    let d = c.prepend(3)
    let e = a.prepend(10)

    h.expect_eq[U64](a.size(), 0)
    h.expect_eq[U64](b.size(), 1)
    h.expect_eq[U64](c.size(), 2)
    h.expect_eq[U64](d.size(), 3)
    h.expect_eq[U64](e.size(), 1)

    try h.expect_eq[U32](b.head(), 1) else error end
    try h.expect_eq[U64](b.tail().size(), 0) else error end
    try h.expect_eq[U32](c.head(), 2) else error end
    try h.expect_eq[U64](c.tail().size(), 1) else error end
    try h.expect_eq[U32](d.head(), 3) else error end
    try h.expect_eq[U64](d.tail().size(), 2) else error end
    try h.expect_eq[U32](e.head(), 10) else error end
    try h.expect_eq[U64](e.tail().size(), 0) else error end

    true

class iso _TestFrom is UnitTest
  fun name(): String => "persistent-data/ListT/from()"

  fun apply(h: TestHelper): TestResult ? =>
    let l1 = ListT.from[U32]([1, 2, 3])
    h.expect_eq[U64](l1.size(), 3)
    try h.expect_eq[U32](l1.head(), 1) else error end

    true

class iso _TestConcat is UnitTest
  fun name(): String => "persistent-data/List/concat()"

  fun apply(h: TestHelper): TestResult ? =>
    let l1 = ListT.from[U32]([1, 2, 3])
    let l2 = ListT.from[U32]([4, 5, 6])
    let l3 = l1.concat(l2)
    let l4 = l3.reverse()
    h.expect_eq[U64](l3.size(), 6)
    try h.expect_true(ListT.eq[U32](l3, ListT.from[U32]([1,2,3,4,5,6]))) else error end
    try h.expect_true(ListT.eq[U32](l4, ListT.from[U32]([6,5,4,3,2,1]))) else error end

    true

class iso _TestMap is UnitTest
  fun name(): String => "persistent-data/ListT/map()"

  fun apply(h: TestHelper): TestResult ? =>
    let l5 = ListT.from[U32]([1, 2, 3]).map[U32](lambda(x: U32): U32 => x * 2 end)
    try h.expect_true(ListT.eq[U32](l5, ListT.from[U32]([2,4,6]))) else error end

    true

class iso _TestFlatMap is UnitTest
  fun name(): String => "persistent-data/ListT/flat_map()"

  fun apply(h: TestHelper): TestResult ? =>
    let f = lambda(x: U32): List[U32] ? => ListT.from[U32]([x - 1, x, x + 1]) end
    let l6 = ListT.from[U32]([2, 5, 8]).flat_map[U32](f)
    try h.expect_true(ListT.eq[U32](l6, ListT.from[U32]([1,2,3,4,5,6,7,8,9]))) else error end

    true

class iso _TestFilter is UnitTest
  fun name(): String => "persistent-data/ListT/filter()"

  fun apply(h: TestHelper): TestResult ? =>
    let isEven = lambda(x: U32): Bool => x % 2 == 0 end
    let l7 = ListT.from[U32]([1,2,3,4,5,6,7,8]).filter(isEven)
    try h.expect_true(ListT.eq[U32](l7, ListT.from[U32]([2,4,6,8]))) else error end

    true

class iso _TestFold is UnitTest
  fun name(): String => "persistent-data/ListT/fold()"

  fun apply(h: TestHelper): TestResult ? =>
    let add = lambda(acc: U32, x: U32): U32 => acc + x end
    let value = ListT.from[U32]([1,2,3]).fold[U32](add, 0)
    h.expect_eq[U32](value, 6)

    let doubleAndPrepend = lambda(acc: List[U32], x: U32): List[U32] ? => acc.prepend(x * 2) end
    let l8 = ListT.from[U32]([1,2,3]).fold[List[U32]](doubleAndPrepend, ListT.empty[U32]())
    try h.expect_true(ListT.eq[U32](l8, ListT.from[U32]([6,4,2]))) else error end

    true

class iso _TestEveryExists is UnitTest
  fun name(): String => "persistent-data/ListT/every()exists()"

  fun apply(h: TestHelper): TestResult ? =>
    let isEven = lambda(x: U32): Bool => x % 2 == 0 end
    let l9 = ListT.from[U32]([4,2,10])
    let l10 = ListT.from[U32]([1,1,3])
    let l11 = ListT.from[U32]([1,1,2])
    let l12 = ListT.from[U32]([2,2,3])
    let l13 = ListT.empty[U32]()
    try h.expect_eq[Bool](l9.every(isEven), true) else error end
    try h.expect_eq[Bool](l10.every(isEven), false) else error end
    try h.expect_eq[Bool](l11.every(isEven), false) else error end
    try h.expect_eq[Bool](l12.every(isEven), false) else error end
    try h.expect_eq[Bool](l13.every(isEven), true) else error end
    try h.expect_eq[Bool](l9.exists(isEven), true) else error end
    try h.expect_eq[Bool](l10.exists(isEven), false) else error end
    try h.expect_eq[Bool](l11.exists(isEven), true) else error end
    try h.expect_eq[Bool](l12.exists(isEven), true) else error end
    try h.expect_eq[Bool](l13.exists(isEven), false) else error end

    true

class iso _TestPartition is UnitTest
  fun name(): String => "persistent-data/ListT/partition()"

  fun apply(h: TestHelper): TestResult ? =>
    let isEven = lambda(x: U32): Bool => x % 2 == 0 end
    let l = ListT.from[U32]([1,2,3,4,5,6])
    (let hits, let misses) = l.partition(isEven)
    try h.expect_true(ListT.eq[U32](hits, ListT.from[U32]([2,4,6]))) else error end
    try h.expect_true(ListT.eq[U32](misses, ListT.from[U32]([1,3,5]))) else error end

    true

class iso _TestDrop is UnitTest
  fun name(): String => "persistent-data/List/drop()"

  fun apply(h: TestHelper): TestResult ? =>
    let l = ListT.from[String](["a","b","c","d","e"])
    let l2 = ListT.from[U32]([1,2])
    let empty = ListT.empty[String]()
    try h.expect_true(ListT.eq[String](l.drop(3), ListT.from[String](["d","e"]))) else error end
    try h.expect_true(ListT.eq[U32](l2.drop(3), ListT.empty[U32]())) else error end
    try h.expect_true(ListT.eq[String](empty.drop(3), ListT.empty[String]())) else error end
    true

class iso _TestDropWhile is UnitTest
  fun name(): String => "persistent-data/List/drop_while()"

  fun apply(h: TestHelper): TestResult ? =>
    let isEven = lambda(x: U32): Bool => x % 2 == 0 end
    let l = ListT.from[U32]([4,2,6,1,3,4,6])
    let empty = ListT.empty[U32]()
    try h.expect_true(ListT.eq[U32](l.drop_while(isEven), ListT.from[U32]([1,3,4,6]))) else error end
    try h.expect_true(ListT.eq[U32](empty.drop_while(isEven), ListT.empty[U32]())) else error end
    true

class iso _TestTake is UnitTest
  fun name(): String => "persistent-data/List/take()"

  fun apply(h: TestHelper): TestResult ? =>
    let l = ListT.from[String](["a","b","c","d","e"])
    let l2 = ListT.from[U32]([1,2])
    let empty = ListT.empty[String]()
    try h.expect_true(ListT.eq[String](l.take(3), ListT.from[String](["a","b","c"]))) else error end
    try h.expect_true(ListT.eq[U32](l2.take(3), ListT.from[U32]([1,2]))) else error end
    try h.expect_true(ListT.eq[String](empty.take(3), ListT.empty[String]())) else error end
    true

class iso _TestTakeWhile is UnitTest
  fun name(): String => "persistent-data/List/take_while()"

  fun apply(h: TestHelper): TestResult ? =>
    let isEven = lambda(x: U32): Bool => x % 2 == 0 end
    let l = ListT.from[U32]([4,2,6,1,3,4,6])
    let empty = ListT.empty[U32]()
    try h.expect_true(ListT.eq[U32](l.take_while(isEven), ListT.from[U32]([4,2,6]))) else error end
    try h.expect_true(ListT.eq[U32](empty.take_while(isEven), ListT.empty[U32]())) else error end
    true