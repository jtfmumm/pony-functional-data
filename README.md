# pony-functional-data
Functional data structures and transformations for the Pony programming language

## persistent-data/Map

A persistent immutable map based on the Hash Array Mapped Trie described by Bagwell in
this paper: http://lampwww.epfl.ch/papers/idealhashtrees.pdf and inspired by
Clojure persistent maps (using path copying for sharing structure).

Currently has the following methods:
```
  (For K: (Hashable val & Equatable[K] val) and V: Any val)

  fun size(): U64  
    
  fun apply(k: K): (V | None) ?
    
  fun get(k: K): (V | None) ?

  fun getOption(k: K): Option[V] ?

  fun getOrElse(k: K, v: V): V ?
    
  fun put(k: K, v: V): Map[K,V] ?
  
  fun contains(k: K): Bool ?

  fun remove(k: K): Map[K,V] ?
```

There is also a primitive called Maps with helper methods:
```
  //Creates an empty Map
  empty[K,V](): Map[K,V]

  //Creates a Map from an array of tuples (k, v)
  from[K,V](arr: Array[(K, V)]): Map[K,V]
```

## persistent-data/List, Lists

Immutable linked list

Currently has the following methods:
```
  size(): U64

  is_empty(): Bool

  is_non_empty(): Bool

  head(): A ?

  tail(): List[A] ?

  reverse(): List[A]

  prepend(a: A): List[A]

  concat(l: List[A]): List[A]

  map[B: Any val](f: Fn1[A!,B^]): List[B] ?

  flat_map[B: Any val](f: Fn1[A!,List[B]]): List[B] ?

  for_each(f: SeFn1[A!]) ?

  filter(f: Fn1[A!, Bool]): List[A] ?

  fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B ?

  every(f: Fn1[A!,Bool]): Bool ?

  exists(f: Fn1[A!,Bool]): Bool ?

  partition(f: Fn1[A!,Bool]): (List[A], List[A]) ?

  drop(n: U64): List[A]

  drop_while(f: Fn1[A!,Bool]): List[A] ?

  take(n: U64): List[A]

  take_while(f: Fn1[A!,Bool]): List[A] ?

```

There is also a primitive called Lists with helper methods:
```
  //Returns empty List of As
  empty[A: Any val](): List[A]

  cons[A: Any val](a: A, t: List[A]): List[A]

  //Create a list from an Array of As
  //  e.g. ListT.from[U32]([1, 2, 3, 4])
  from[A: Any val](arr: Array[A]): List[A]

  flatten[A: Any val](l: List[List[A]]): List[A]

  eq[A: Equatable[A] val](l1: List[A], l2: List[A]): Bool ?

```

## persistent-data/Option

An Option[V] is either an ONone[V] or an OSome[V]

Currently has the following methods:
```
  is_empty(): Bool

  is_non_empty(): Bool

  value(): V ?

  map[B: Any val](f: Fn1[V!,B^]): Option[B] ?

  flat_map[B: Any val](f: Fn1[V!,Option[B]]): Option[B] ?

  filter(f: Fn1[V!,Bool]): Option[V] ?
```


## mutable-data/Lists

Helper methods for the "collections" package mutable List

The primitive mutable-data/Lists has the following methods:

```
    unit[A](a: A): List[A]

    map[A: Any #read, B](l: List[A], f: Fn1[A!, B^]): List[B]

    flat_map[A: Any #read, B](l: List[A], f: Fn1[A!,List[B]]): List[B]

    flatten[A](l: List[List[A]]): List[A]

    filter[A: Any #read](l: List[A], f: Fn1[A!, Bool]): List[A]

    fold[A: Any #read,B: Any #read](l: List[A], f: Fn2[B!,A!,B^], acc: B): B

    every[A: Any #read](l: List[A], f: Fn1[A!,Bool]): Bool

    exists[A: Any #read](l: List[A], f: Fn1[A!,Bool]): Bool

    partition[A: Any #read](l: List[A], f: Fn1[A!,Bool]): (List[A], List[A])

    drop[A: Any #read](l: List[A], n: USize): List[A]

    take[A: Any #read](l: List[A], n: USize): List[A]

    take_while[A: Any #read](l: List[A], f: Fn1[A!,Bool]): List[A]
```

## function-types

Provides abstract functional interfaces:
```
    Fn0[OUT]

    Fn1[IN1: Any #read,OUT]

    Fn2[IN1: Any #read,IN2: Any #read,OUT]

    Fn3[IN1: Any #read,IN2: Any #read,IN3: Any #read,OUT]

    Fn4[IN1: Any #read,IN2: Any #read,IN3: Any #read,IN4: Any #read,OUT]

    Fn5[IN1: Any #read,IN2: Any #read,IN3: Any #read,IN4: Any #read,IN5: Any #read,OUT]  

    // Side effecting function
    SeFn1[IN1: Any #read]
```
