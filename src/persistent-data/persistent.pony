"""
# Persistent Collections Package

## List

A persistent list with functional transformations.

### Usage

```
let l1 = Lists[U32]([2, 4, 6, 8]) // List(2, 4, 6, 8)

let empty = Lists[U32].empty() // List()

// prepend() returns a new List, leaving the
// old list unchanged
let l2 = empty.prepend(3) // List(3)
let l3 = l2.prepend(2) // List(2, 3)
let l4 = l3.prepend(1) // List(1, 2, 3)
let l4_head = l4.head() // 1
let l4_tail = l4.tail() // List(2, 3)

h.assert_eq[U32](l4_head, 1)
h.assert_true(Lists[U32].eq(l4, Lists[U32]([1, 2, 3])))
h.assert_true(Lists[U32].eq(l4_tail, Lists[U32]([2, 3])))

let doubled = l4.map[U32](lambda(x: U32): U32 => x * 2 end)

h.assert_true(Lists[U32].eq(doubled, Lists[U32]([2, 4, 6])))

```

## Map

A persistent map based on Bagwell's hash array mapped trie algorithm.

### Usage

```
let empty: Map[String,U32] = Maps.empty[String,U32]() // {}
// Update returns a new map with the provided key set
// to the provided value. The old map is unchanged.
let m2 = m1.update("a", 5) // {a: 5}
let m3 = m2.update("b", 10) // {a: 5, b: 10}
let m4 = m3.remove("a") // {b: 10}

// You can create a new map from key value pairs.
let map = Maps.from[String,U32]([("a", 2), ("b", 3)]) // {a: 2, b: 3}
```
"""