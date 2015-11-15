use "../function-types"

trait val List[A: Any val]
  fun size(): U64
  fun is_empty(): Bool
  fun is_non_empty(): Bool => not(is_empty())
  fun head(): this->A ?
  fun tail(): this->List[A] ?
  fun val reverse(): this->List[A] ?
  fun val prepend(a: A): this->List[A]^ ?
  fun val concat(l: List[A]): this->List[A]^ ?
  fun map[B: Any val](f: Fn1[A!,B^]): this->List[B]^ ?
  fun flatMap[B: Any val](f: Fn1[A!,List[B]]): this->List[B]^ ?
  fun filter(f: Fn1[A!, Bool]): List[A] ?
  fun fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B ?
  fun every(f: Fn1[A!,Bool]): Bool ?
  fun exists(f: Fn1[A!,Bool]): Bool ?
  fun partition(f: Fn1[A!,Bool]): (List[A], List[A]) ?
  fun drop(n: U64): List[A] ?
  fun take(n: U64): List[A] ?

class val LNil[A: Any val] is List[A]
  new create() => this

  fun size(): U64 => 0
  fun is_empty(): Bool => true
  fun head(): this->A ? => error
  fun tail(): this->List[A] ? => error
  fun val reverse(): this->List[A] => ListT.empty[A]()
  fun val prepend(a: A): this->List[A]^ ? =>
    LCons[A](consume a, ListT.empty[A]()) as List[A]
  fun val concat(l: List[A]): this->List[A]^ => l
  fun map[B: Any val](f: Fn1[A!,B^]): this->List[B]^ => recover val LNil[B] end
  fun flatMap[B: Any val](f: Fn1[A!,List[B]]): this->List[B]^ => recover val LNil[B] end
  fun filter(f: Fn1[A!, Bool]): List[A] => ListT.empty[A]()
  fun fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B => acc
  fun every(f: Fn1[A!,Bool]): Bool => true
  fun exists(f: Fn1[A!,Bool]): Bool => false
  fun partition(f: Fn1[A!,Bool]): (List[A], List[A]) =>
    (ListT.empty[A](), ListT.empty[A]())
  fun drop(n: U64): List[A] => ListT.empty[A]()
  fun take(n: U64): List[A] => ListT.empty[A]()

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
  fun head(): this->A => _head
  fun tail(): this->List[A] ? => _tail as this->List[A]
  fun val reverse(): this->List[A] ? => ListT.reverse[A](this)
  fun val prepend(a: A): this->List[A]^ ? =>
    LCons[A](consume a, this) as List[A]
  fun val concat(l: List[A]): this->List[A]^ ? => _concat(l, this.reverse())
  fun val _concat(l: List[A], acc: List[A]): this->List[A]^ ? =>
    if l.is_empty() then
      acc.reverse()
    else
      _concat(l.tail(), acc.prepend(l.head()))
    end
  fun map[B: Any val](f: Fn1[A!,B^]): this->List[B]^ ? =>
    let cur: List[A] = LCons[A](this.head(), this.tail() as List[A])
    _map[B](cur, f, ListT.empty[B]())
  fun _map[B: Any val](l: List[A], f: Fn1[A!,B^], acc: List[B]): this->List[B]^ ? =>
    if (l.is_empty()) then return acc.reverse() end
    _map[B](l.tail(), f, acc.prepend(f(l.head())))
  fun flatMap[B: Any val](f: Fn1[A!,List[B]]): this->List[B]^ ? =>
    let cur: List[A] = LCons[A](this.head(), this.tail() as List[A])
    _flatMap[B](cur, f, ListT.empty[B]())
  fun _flatMap[B: Any val](l: List[A], f: Fn1[A!,List[B]], acc: List[B]): this->List[B]^ ? =>
    if (l.is_empty()) then return acc.reverse() end
    _flatMap[B](l.tail(), f, ListT._rev_prepend[B](f(l.head()), acc))
  fun filter(f: Fn1[A!, Bool]): List[A] ? =>
    let cur: List[A] = LCons[A](this.head(), this.tail() as List[A])
    _filter(cur, f, ListT.empty[A]())
  fun _filter(l: List[A], f: Fn1[A!, Bool], acc: List[A]): List[A] ? =>
    if (l.is_empty()) then return acc.reverse() end
    if (f(l.head())) then
      _filter(l.tail(), f, acc.prepend(l.head()))
    else
      _filter(l.tail(), f, acc)
    end
  fun fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B ? =>
    _fold[B](this.tail(), f, f(acc, this.head()))
  fun _fold[B: Any val](l: List[A], f: Fn2[B!,A!,B^], acc: B): B ? =>
    if (l.is_empty()) then return acc end
    _fold[B](l.tail(), f, f(acc, l.head()))
  fun every(f: Fn1[A!,Bool]): Bool ? =>
    if (f(this.head())) then _every(this.tail(), f) else false end
  fun _every(l: List[A], f: Fn1[A!,Bool]): Bool ? =>
    if (l.is_empty()) then
      true
    elseif (f(l.head())) then
      _every(l.tail(), f)
    else
      false
    end
  fun exists(f: Fn1[A!,Bool]): Bool ? =>
    if (f(this.head())) then true else _exists(this.tail(), f) end
  fun _exists(l: List[A], f: Fn1[A!,Bool]): Bool ? =>
    if (l.is_empty()) then
      false
    elseif (f(l.head())) then
      true
    else
      _exists(l.tail(), f)
    end
  fun partition(f: Fn1[A!,Bool]): (List[A], List[A]) ? =>
    var hits = ListT.empty[A]()
    var misses = ListT.empty[A]()
    var cur: List[A] = LCons[A](this.head(), this.tail() as List[A])
    while(cur.is_non_empty()) do
      let next = cur.head()
      if (f(next)) then hits = hits.prepend(next) else misses = misses.prepend(next) end
      cur = cur.tail() as List[A]
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

primitive ListT
  fun val empty[A: Any val](): List[A] => recover val LNil[A] end
  fun val cons[A: Any val](a: A, t: List[A]): List[A] => LCons[A](consume a, t)

  fun val from[A: Any val](arr: Array[A]): List[A] ? =>
    var lst = this.empty[A]()
    for v in arr.values() do
      lst = lst.prepend(v)
    end
    lst.reverse()

  fun val reverse[A: Any val](l: List[A]): List[A] ? => _reverse[A](l, ListT.empty[A]())
  fun val _reverse[A: Any val](l: List[A], acc: List[A]): List[A] ? =>
    if l.is_empty() then
      acc
    else
      _reverse[A](l.tail(), acc.prepend(l.head()))
    end

  fun val flatten[A: Any val](l: List[List[A]]): List[A] ? => _flatten[A](l, ListT.empty[A]())
  fun val _flatten[A: Any val](l: List[List[A]], acc: List[A]): List[A] ? =>
    if l.is_empty() then
      acc.reverse()
    else
      _flatten[A](l.tail(), _rev_prepend[A](l.head(), acc))
    end

  fun val _rev_prepend[A: Any val](l: List[A], targetL: List[A]): List[A] ? =>
    // Prepends l in reverse order onto targetL
    if (l.is_empty()) then
      targetL
    else
      _rev_prepend[A](l.tail(), targetL.prepend(l.head()))
    end

  fun eq[A: Equatable[A] val](l1: List[A], l2: List[A]): Bool ? =>
    if (l1.is_empty() and l2.is_empty()) then
      true
    elseif (l1.is_empty() and l2.is_non_empty()) then
      false
    elseif (l1.is_non_empty() and l2.is_empty()) then
      false
    elseif (l1.head() != l2.head()) then
      false
    else
      eq[A](l1.tail(), l2.tail())
    end
