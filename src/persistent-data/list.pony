use "../function-types"

trait val List[A: Any val]
  fun size(): U64
  fun is_empty(): Bool
  fun is_non_empty(): Bool => not(is_empty())
  fun head(): A ?
  fun tail(): List[A] ?
  fun val reverse(): List[A]
  fun val prepend(a: A): List[A]
  fun val concat(l: List[A]): List[A]
  fun val map[B: Any val](f: Fn1[A!,B^]): List[B]
  fun val flat_map[B: Any val](f: Fn1[A!,List[B]]): List[B]
  fun val filter(f: Fn1[A!, Bool]): List[A]
  fun val fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B
  fun every(f: Fn1[A!,Bool]): Bool
  fun exists(f: Fn1[A!,Bool]): Bool
  fun partition(f: Fn1[A!,Bool]): (List[A], List[A]) ?
  fun drop(n: U64): List[A] ?
  fun drop_while(f: Fn1[A!,Bool]): List[A] ?
  fun take(n: U64): List[A] ?
  fun take_while(f: Fn1[A!,Bool]): List[A] ?

class val LNil[A: Any val] is List[A]
  new create() => this

  fun size(): U64 => 0

  fun is_empty(): Bool => true

  fun head(): A ? => error

  fun tail(): List[A] ? => error

  fun val reverse(): List[A] => ListT.empty[A]()

  fun val prepend(a: A): List[A] => LCons[A](consume a, ListT.empty[A]())

  fun val concat(l: List[A]): List[A] => l

  fun val map[B: Any val](f: Fn1[A!,B^]): List[B] => ListT.empty[B]()

  fun val flat_map[B: Any val](f: Fn1[A!,List[B]]): List[B] => ListT.empty[B]()

  fun val filter(f: Fn1[A!, Bool]): List[A] => ListT.empty[A]()

  fun val fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B => acc

  fun every(f: Fn1[A!,Bool]): Bool => true

  fun exists(f: Fn1[A!,Bool]): Bool => false

  fun partition(f: Fn1[A!,Bool]): (List[A], List[A]) =>
    (ListT.empty[A](), ListT.empty[A]())

  fun drop(n: U64): List[A] => ListT.empty[A]()

  fun drop_while(f: Fn1[A!,Bool]): List[A] => ListT.empty[A]()

  fun take(n: U64): List[A] => ListT.empty[A]()

  fun take_while(f: Fn1[A!,Bool]): List[A] => ListT.empty[A]()

class val LCons[A: Any val] is List[A]
  let _size: U64
  let _head: A
  let _tail: List[A]

  new val create(a: A, t: List[A]) =>
    _head = consume a
    _tail = consume t
    _size = 1 + _tail.size()

  fun size(): U64 => _size

  fun is_empty(): Bool => false

  fun head(): A => _head

  fun tail(): List[A] => _tail //as this->List[A]

  fun val reverse(): List[A] => ListT.reverse[A](this)

  fun val prepend(a: A): List[A] => LCons[A](consume a, this)

  fun val concat(l: List[A]): List[A] => _concat(l, this.reverse())
  fun val _concat(l: List[A], acc: List[A]): List[A] =>
    try
      _concat(l.tail(), acc.prepend(l.head()))
    else
      acc.reverse()
    end

  fun val map[B: Any val](f: Fn1[A!,B^]): List[B] =>
    let cur: List[A] = LCons[A](this.head(), this.tail())
    _map[B](cur, f, ListT.empty[B]())
  fun val _map[B: Any val](l: List[A], f: Fn1[A!,B^], acc: List[B]): List[B] =>
    try
      _map[B](l.tail(), f, acc.prepend(f(l.head())))
    else
      acc.reverse()
    end

  fun val flat_map[B: Any val](f: Fn1[A!,List[B]]): List[B] =>
    let cur: List[A] = LCons[A](this.head(), this.tail())
    _flat_map[B](cur, f, ListT.empty[B]())
  fun val _flat_map[B: Any val](l: List[A], f: Fn1[A!,List[B]], acc: List[B]): List[B] =>
    try
      _flat_map[B](l.tail(), f, ListT._rev_prepend[B](f(l.head()), acc))
    else
      acc.reverse()
    end

  fun val filter(f: Fn1[A!, Bool]): List[A] =>
    let cur: List[A] = LCons[A](this.head(), this.tail())
    _filter(cur, f, ListT.empty[A]())
  fun val _filter(l: List[A], f: Fn1[A!, Bool], acc: List[A]): List[A] =>
    try
      if (f(l.head())) then
        _filter(l.tail(), f, acc.prepend(l.head()))
      else
        _filter(l.tail(), f, acc)
      end
    else
      acc.reverse()
    end

  fun fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B =>
    let cur: List[A] = LCons[A](this.head(), this.tail())
    _fold[B](cur, f, acc)
  fun _fold[B: Any val](l: List[A], f: Fn2[B!,A!,B^], acc: B): B =>
    try
      _fold[B](l.tail(), f, f(acc, l.head()))
    else
      acc
    end

  fun every(f: Fn1[A!,Bool]): Bool =>
    let cur: List[A] = LCons[A](this.head(), this.tail())
    _every(cur, f)
  fun _every(l: List[A], f: Fn1[A!,Bool]): Bool =>
    try
      if (f(l.head())) then
        _every(l.tail(), f)
      else
        false
      end
    else
      true
    end

  fun exists(f: Fn1[A!,Bool]): Bool =>
    let cur: List[A] = LCons[A](this.head(), this.tail())
    _exists(cur, f)
  fun _exists(l: List[A], f: Fn1[A!,Bool]): Bool =>
    try
      if (f(l.head())) then
        true
      else
        _exists(l.tail(), f)
      end
    else
      false
    end

  fun partition(f: Fn1[A!,Bool]): (List[A], List[A]) ? =>
    var hits = ListT.empty[A]()
    var misses = ListT.empty[A]()
    var cur: List[A] = LCons[A](this.head(), this.tail())
    while(cur.is_non_empty()) do
      let next = cur.head()
      if (f(next)) then hits = hits.prepend(next) else misses = misses.prepend(next) end
      cur = cur.tail()
    end
    (hits.reverse(), misses.reverse())

  fun drop(n: U64): List[A] ? =>
    var cur: List[A] = LCons[A](this.head(), this.tail() as List[A])
    if cur.size() <= n then return ListT.empty[A]() end
    var count = n
    while(count > 0) do
      cur = cur.tail()
      count = count - 1
    end
    cur

  fun drop_while(f: Fn1[A!,Bool]): List[A] ? =>
    var cur: List[A] = LCons[A](this.head(), this.tail() as List[A])
    while(f(cur.head())) do
      cur = cur.tail()
    end
    cur

  fun take(n: U64): List[A] ? =>
    var cur: List[A] = LCons[A](this.head(), this.tail() as List[A])
    if cur.size() <= n then return cur end
    var count = n
    var res = ListT.empty[A]()
    while(count > 0) do
      res = res.prepend(cur.head())
      cur = cur.tail()
      count = count - 1
    end
    res.reverse()

  fun take_while(f: Fn1[A!,Bool]): List[A] ? =>
    var cur: List[A] = LCons[A](this.head(), this.tail() as List[A])
    var res = ListT.empty[A]()
    while(f(cur.head())) do
      res = res.prepend(cur.head())
      cur = cur.tail()
    end
    res.reverse()

primitive ListT
  fun val empty[T: Any val](): List[T] => recover val LNil[T] end

  fun val cons[T: Any val](a: T, t: List[T]): List[T] => LCons[T](consume a, t)

  fun val from[T: Any val](arr: Array[T]): List[T] =>
    var lst = this.empty[T]()
    for v in arr.values() do
      lst = lst.prepend(v)
    end
    lst.reverse()

  fun val reverse[T: Any val](l: List[T]): List[T] => _reverse[T](l, ListT.empty[T]())
  fun val _reverse[T: Any val](l: List[T], acc: List[T]): List[T] =>
    try
      _reverse[T](l.tail(), acc.prepend(l.head()))
    else
      acc
    end

  fun val flatten[T: Any val](l: List[List[T]]): List[T] => _flatten[T](l, ListT.empty[T]())
  fun val _flatten[T: Any val](l: List[List[T]], acc: List[T]): List[T] =>
    try
      _flatten[T](l.tail(), _rev_prepend[T](l.head(), acc))
    else
      acc.reverse()
    end

  fun val _rev_prepend[T: Any val](l: List[T], target_l: List[T]): List[T] =>
    // Prepends l in reverse order onto targetL
    try
      _rev_prepend[T](l.tail(), target_l.prepend(l.head()))
    else
      target_l
    end

  fun eq[T: Equatable[T] val](l1: List[T], l2: List[T]): Bool ? =>
    if (l1.is_empty() and l2.is_empty()) then
      true
    elseif (l1.is_empty() and l2.is_non_empty()) then
      false
    elseif (l1.is_non_empty() and l2.is_empty()) then
      false
    elseif (l1.head() != l2.head()) then
      false
    else
      eq[T](l1.tail(), l2.tail())
    end
