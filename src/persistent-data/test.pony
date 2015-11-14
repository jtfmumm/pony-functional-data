use "ponytest"

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
//    a.push(0).push(1).push(2)

//    let f = lambda(a: U32): U32 => consume a * 2 end
//    let c = ListT.map[U32,U32](a, f)

//    h.expect_eq[U32](c(0), 0)
//    h.expect_eq[U32](c(1), 2)
//    h.expect_eq[U32](c(2), 4)

    true
