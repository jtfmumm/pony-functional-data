use "ponytest"
use "../function-types"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestList)


class iso _TestList is UnitTest
  fun name(): String => "persistent-data/List"

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

    let l1 = ListT.from[U32]([1, 2, 3])
    h.expect_eq[U64](l1.size(), 3)
    try h.expect_eq[U32](l1.head(), 1) else error end

    let l2 = ListT.from[U32]([4, 5, 6])
    let l3 = l1.concat(l2)
    let l4 = l3.reverse()
    h.expect_eq[U64](l3.size(), 6)
    try h.expect_true(ListT.eq[U32](l3, ListT.from[U32]([1,2,3,4,5,6]))) end
    try h.expect_true(ListT.eq[U32](l4, ListT.from[U32]([6,5,4,3,2,1]))) end

    let l5 = ListT.from[U32]([1, 2, 3]).map[U32](lambda(x: U32): U32 => x * 2 end)
    try h.expect_true(ListT.eq[U32](l5, ListT.from[U32]([2,4,6]))) end

    let g = lambda(x: U32): List[U32] ? => ListT.from[U32]([x - 1, x, x + 1]) end
    let l6 = ListT.from[U32]([2, 5, 8]).flatMap[U32](g)
    try h.expect_true(ListT.eq[U32](l6, ListT.from[U32]([1,2,3,4,5,6,7,8,9]))) end


    true
