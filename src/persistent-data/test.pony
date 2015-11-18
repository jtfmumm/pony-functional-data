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
    test(_TestBitOps)
    test(_TestHAMTMap)

class iso _TestPrepend is UnitTest
  fun name(): String => "persistent-data/List/prepend()"

  fun apply(h: TestHelper): TestResult ? =>
    let a = Lists.empty[U32]()
    let b = Lists.cons[U32](1, Lists.empty[U32]())
    let c = Lists.cons[U32](2, b)
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
  fun name(): String => "persistent-data/Lists/from()"

  fun apply(h: TestHelper): TestResult ? =>
    let l1 = Lists.from[U32]([1, 2, 3])
    h.expect_eq[U64](l1.size(), 3)
    try h.expect_eq[U32](l1.head(), 1) else error end

    true

class iso _TestConcat is UnitTest
  fun name(): String => "persistent-data/List/concat()"

  fun apply(h: TestHelper): TestResult ? =>
    let l1 = Lists.from[U32]([1, 2, 3])
    let l2 = Lists.from[U32]([4, 5, 6])
    let l3 = l1.concat(l2)
    let l4 = l3.reverse()
    h.expect_eq[U64](l3.size(), 6)
    try h.expect_true(Lists.eq[U32](l3, Lists.from[U32]([1,2,3,4,5,6]))) else error end
    try h.expect_true(Lists.eq[U32](l4, Lists.from[U32]([6,5,4,3,2,1]))) else error end

    true

class iso _TestMap is UnitTest
  fun name(): String => "persistent-data/Lists/map()"

  fun apply(h: TestHelper): TestResult ? =>
    let l5 = Lists.from[U32]([1, 2, 3]).map[U32](lambda(x: U32): U32 => x * 2 end)
    try h.expect_true(Lists.eq[U32](l5, Lists.from[U32]([2,4,6]))) else error end

    true

class iso _TestFlatMap is UnitTest
  fun name(): String => "persistent-data/Lists/flat_map()"

  fun apply(h: TestHelper): TestResult ? =>
    let f = lambda(x: U32): List[U32] => Lists.from[U32]([x - 1, x, x + 1]) end
    let l6 = Lists.from[U32]([2, 5, 8]).flat_map[U32](f)
    try h.expect_true(Lists.eq[U32](l6, Lists.from[U32]([1,2,3,4,5,6,7,8,9]))) else error end

    true

class iso _TestFilter is UnitTest
  fun name(): String => "persistent-data/Lists/filter()"

  fun apply(h: TestHelper): TestResult ? =>
    let is_even = lambda(x: U32): Bool => x % 2 == 0 end
    let l7 = Lists.from[U32]([1,2,3,4,5,6,7,8]).filter(is_even)
    try h.expect_true(Lists.eq[U32](l7, Lists.from[U32]([2,4,6,8]))) else error end

    true

class iso _TestFold is UnitTest
  fun name(): String => "persistent-data/Lists/fold()"

  fun apply(h: TestHelper): TestResult ? =>
    let add = lambda(acc: U32, x: U32): U32 => acc + x end
    let value = Lists.from[U32]([1,2,3]).fold[U32](add, 0)
    h.expect_eq[U32](value, 6)

    let doubleAndPrepend = lambda(acc: List[U32], x: U32): List[U32] => acc.prepend(x * 2) end
    let l8 = Lists.from[U32]([1,2,3]).fold[List[U32]](doubleAndPrepend, Lists.empty[U32]())
    try h.expect_true(Lists.eq[U32](l8, Lists.from[U32]([6,4,2]))) else error end

    true

class iso _TestEveryExists is UnitTest
  fun name(): String => "persistent-data/Lists/every()exists()"

  fun apply(h: TestHelper): TestResult =>
    let is_even = lambda(x: U32): Bool => x % 2 == 0 end
    let l9 = Lists.from[U32]([4,2,10])
    let l10 = Lists.from[U32]([1,1,3])
    let l11 = Lists.from[U32]([1,1,2])
    let l12 = Lists.from[U32]([2,2,3])
    let l13 = Lists.empty[U32]()
    h.expect_eq[Bool](l9.every(is_even), true)
    h.expect_eq[Bool](l10.every(is_even), false)
    h.expect_eq[Bool](l11.every(is_even), false)
    h.expect_eq[Bool](l12.every(is_even), false)
    h.expect_eq[Bool](l13.every(is_even), true)
    h.expect_eq[Bool](l9.exists(is_even), true)
    h.expect_eq[Bool](l10.exists(is_even), false)
    h.expect_eq[Bool](l11.exists(is_even), true)
    h.expect_eq[Bool](l12.exists(is_even), true)
    h.expect_eq[Bool](l13.exists(is_even), false)

    true

class iso _TestPartition is UnitTest
  fun name(): String => "persistent-data/Lists/partition()"

  fun apply(h: TestHelper): TestResult ? =>
    let is_even = lambda(x: U32): Bool => x % 2 == 0 end
    let l = Lists.from[U32]([1,2,3,4,5,6])
    (let hits, let misses) = l.partition(is_even)
    try h.expect_true(Lists.eq[U32](hits, Lists.from[U32]([2,4,6]))) else error end
    try h.expect_true(Lists.eq[U32](misses, Lists.from[U32]([1,3,5]))) else error end

    true

class iso _TestDrop is UnitTest
  fun name(): String => "persistent-data/List/drop()"

  fun apply(h: TestHelper): TestResult ? =>
    let l = Lists.from[String](["a","b","c","d","e"])
    let l2 = Lists.from[U32]([1,2])
    let empty = Lists.empty[String]()
    try h.expect_true(Lists.eq[String](l.drop(3), Lists.from[String](["d","e"]))) else error end
    try h.expect_true(Lists.eq[U32](l2.drop(3), Lists.empty[U32]())) else error end
    try h.expect_true(Lists.eq[String](empty.drop(3), Lists.empty[String]())) else error end
    true

class iso _TestDropWhile is UnitTest
  fun name(): String => "persistent-data/List/drop_while()"

  fun apply(h: TestHelper): TestResult ? =>
    let is_even = lambda(x: U32): Bool => x % 2 == 0 end
    let l = Lists.from[U32]([4,2,6,1,3,4,6])
    let empty = Lists.empty[U32]()
    try h.expect_true(Lists.eq[U32](l.drop_while(is_even), Lists.from[U32]([1,3,4,6]))) else error end
    try h.expect_true(Lists.eq[U32](empty.drop_while(is_even), Lists.empty[U32]())) else error end
    true

class iso _TestTake is UnitTest
  fun name(): String => "persistent-data/List/take()"

  fun apply(h: TestHelper): TestResult ? =>
    let l = Lists.from[String](["a","b","c","d","e"])
    let l2 = Lists.from[U32]([1,2])
    let empty = Lists.empty[String]()
    try h.expect_true(Lists.eq[String](l.take(3), Lists.from[String](["a","b","c"]))) else error end
    try h.expect_true(Lists.eq[U32](l2.take(3), Lists.from[U32]([1,2]))) else error end
    try h.expect_true(Lists.eq[String](empty.take(3), Lists.empty[String]())) else error end
    true

class iso _TestTakeWhile is UnitTest
  fun name(): String => "persistent-data/List/take_while()"

  fun apply(h: TestHelper): TestResult ? =>
    let is_even = lambda(x: U32): Bool => x % 2 == 0 end
    let l = Lists.from[U32]([4,2,6,1,3,4,6])
    let empty = Lists.empty[U32]()
    try h.expect_true(Lists.eq[U32](l.take_while(is_even), Lists.from[U32]([4,2,6]))) else error end
    try h.expect_true(Lists.eq[U32](empty.take_while(is_even), Lists.empty[U32]())) else error end
    true


class iso _TestBitOps is UnitTest
  fun name(): String => "hamt/_BitOps"

  fun apply(h: TestHelper): TestResult =>
    let a = _BitOps.maskLow(845)
    let b = _BitOps.maskLow(968)
    let c = _BitOps.maskLow(875)
    let d = _BitOps.maskLow(559)
    let e = _BitOps.maskLow(618)
    h.expect_eq[U32](a, 13)
    h.expect_eq[U32](b, 8)
    h.expect_eq[U32](c, 11)
    h.expect_eq[U32](d, 15)
    h.expect_eq[U32](e, 10)

    //1100 00011 11101 01001 10111 or 12711223
    let b0 = _BitOps.bitmapIdxFor(12711223, 0)
    let b1 = _BitOps.bitmapIdxFor(12711223, 1)
    let b2 = _BitOps.bitmapIdxFor(12711223, 2)
    let b3 = _BitOps.bitmapIdxFor(12711223, 3)
    let b4 = _BitOps.bitmapIdxFor(12711223, 4)
    h.expect_eq[U32](b0, 23)
    h.expect_eq[U32](b1, 9)
    h.expect_eq[U32](b2, 29)
    h.expect_eq[U32](b3, 3)
    h.expect_eq[U32](b4, 12)

    let c0 = _BitOps.checkIdxBit(13, 0)
    let c1 = _BitOps.checkIdxBit(13, 1)
    let c2 = _BitOps.checkIdxBit(13, 2)
    let c3 = _BitOps.checkIdxBit(13, 3)
    let c4 = _BitOps.checkIdxBit(13, 4)
    let c5 = _BitOps.checkIdxBit(26, 0)
    let c6 = _BitOps.checkIdxBit(26, 1)
    let c7 = _BitOps.checkIdxBit(26, 2)
    let c8 = _BitOps.checkIdxBit(26, 3)
    let c9 = _BitOps.checkIdxBit(26, 4)
    h.expect_eq[Bool](c0, true)
    h.expect_eq[Bool](c1, false)
    h.expect_eq[Bool](c2, true)
    h.expect_eq[Bool](c3, true)
    h.expect_eq[Bool](c4, false)
    h.expect_eq[Bool](c5, false)
    h.expect_eq[Bool](c6, true)
    h.expect_eq[Bool](c7, false)
    h.expect_eq[Bool](c8, true)
    h.expect_eq[Bool](c9, true)

    let d0 = _BitOps.flipIndexedBitOn(8, 0)
    let d1 = _BitOps.flipIndexedBitOn(8, 1)
    let d2 = _BitOps.flipIndexedBitOn(8, 2)
    let d3 = _BitOps.flipIndexedBitOn(8, 3)
    let d4 = _BitOps.flipIndexedBitOn(8, 4)
    h.expect_eq[U32](d0, 9)
    h.expect_eq[U32](d1, 10)
    h.expect_eq[U32](d2, 12)
    h.expect_eq[U32](d3, 8)
    h.expect_eq[U32](d4, 24)

    let e0 = _BitOps.countPop(13)
    let e1 = _BitOps.countPop(8)
    let e2 = _BitOps.countPop(11)
    let e3 = _BitOps.countPop(15)
    h.expect_eq[U32](e0, 3)
    h.expect_eq[U32](e1, 1)
    h.expect_eq[U32](e2, 3)
    h.expect_eq[U32](e3, 4)

    true

class iso _TestHAMTMap is UnitTest
  fun name(): String => "hamt/Map"

  fun apply(h: TestHelper): TestResult ? =>
    let m1: Map[U32] = MapNode[U32].empty()
    let v1 = m1.get("a")
    let v1b = m1("b")
    let s1 = m1.size()
    h.expect_eq[Bool](isNone(v1), true)
    h.expect_eq[Bool](isValue(v1, 0), false)
    h.expect_eq[Bool](isNone(v1b), true)
    h.expect_eq[Bool](isValue(v1b, 0), false)
    h.expect_eq[U64](s1, 0)
    h.expect_eq[Bool](m1.is_leaf(), false)

    let m2 = m1.put("a", 5)
    let m3 = m2.put("b", 10)
    let m4 = m3.put("a", 4)
    let m5 = m4.put("c", 0)

    h.expect_eq[Bool](isValue(m2.get("a"), 5), true)
    h.expect_eq[Bool](isValue(m3.get("b"), 10), true)
    h.expect_eq[Bool](isValue(m4.get("a"), 4), true)
    h.expect_eq[Bool](isValue(m5.get("c"), 0), true)
    h.expect_eq[Bool](isNone(m5.get("d")), true)

    true

  fun isValue(v: (U32 | None), value: U32): Bool =>
    match v
    | None => false
    | let x: U32 => x == value
    else
      false
    end

  fun isNone(v: (U32 | None)): Bool =>
    match v
    | None => true
    else
      false
    end