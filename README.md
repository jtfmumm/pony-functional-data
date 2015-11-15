# pony-functional-data
Functional data structures and transformations for the Pony programming language


## persistent-data/List

Immutable linked list with the following methods:
```
  size(): U64

  is_empty(): Bool

  is_non_empty(): Bool => not(is_empty())

  head(): A ?

  tail(): List[A] ?

  reverse(): List[A]

  prepend(a: A): List[A]

  concat(l: List[A]): List[A]

  map[B: Any val](f: Fn1[A!,B^]): List[B]

  flat_map[B: Any val](f: Fn1[A!,List[B]]): List[B]

  filter(f: Fn1[A!, Bool]): List[A]

  fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B

  every(f: Fn1[A!,Bool]): Bool

  exists(f: Fn1[A!,Bool]): Bool

  partition(f: Fn1[A!,Bool]): (List[A], List[A])

  drop(n: U64): List[A]

  drop_while(f: Fn1[A!,Bool]): List[A]

  take(n: U64): List[A]

  take_while(f: Fn1[A!,Bool]): List[A]

```

There is also a primitive called ListT with helper methods:
```
  //Returns empty List of As
  empty[A: Any val](): List[A]

  cons[A: Any val](a: A, t: List[A]): List[A]

  //Create a list from an Array of As
  //  e.g. ListT.from[U32]([1, 2, 3, 4])
  from[A: Any val](arr: Array[A]): List[A]

  reverse[A: Any val](l: List[A]): List[A]

  flatten[A: Any val](l: List[List[A]]): List[A]

  eq[A: Equatable[A] val](l1: List[A], l2: List[A]): Bool ?

```

## list-transforms/MListT

Helper methods for the "collections" package mutable List

MListT has the following methods:

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

    drop[A: Any #read](l: List[A], n: U64): List[A]

    take[A: Any #read](l: List[A], n: U64): List[A]

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
```