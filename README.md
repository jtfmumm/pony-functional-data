# pony-transforms
Functional transforms for Pony


## list-transforms/ListT

ListT has the following methods:

```
    unit[A](a: A): List[A]
    map[A: Any #read, B](l: List[A], f: Fn1[A!, B^]): List[B]
    flatMap[A: Any #read, B](l: List[A], f: Fn1[A!,List[B]]): List[B]
    flatten[A](l: List[List[A]]): List[A]
    filter[A: Any #read](l: List[A], f: Fn1[A!, Bool]): List[A]
    fold[A: Any #read,B: Any #read](l: List[A], f: Fn2[B!,A!,B^], acc: B): B
    every[A: Any #read](l: List[A], f: Fn1[A!,Bool]): Bool
    exists[A: Any #read](l: List[A], f: Fn1[A!,Bool]): Bool
    partition[A: Any #read](l: List[A], f: Fn1[A!,Bool]): (List[A], List[A])
    drop[A: Any #read](l: List[A], n: U64): List[A]
    take[A: Any #read](l: List[A], n: U64): List[A]
    takeWhile[A: Any #read](l: List[A], f: Fn1[A!,Bool]): List[A]
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