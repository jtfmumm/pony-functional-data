type List[A: Any val] is (Cons[A] | Nil[A])

primitive Nil[A: Any val]
  fun size(): U64 => 0

  fun is_empty(): Bool => true

  fun is_non_empty(): Bool => false

  fun head(): A ? => error

  fun tail(): List[A] ? => error

  fun reverse(): List[A] => this

  fun prepend(a: A): List[A] => Cons[A](consume a, this)

  fun concat(l: List[A]): List[A] => l

  fun map[B: Any val](f: {(A!): B^} box): List[B] => Nil[B]

  fun flat_map[B: Any val](f: {(A!): List[B]} box): List[B] => Nil[B]

  fun for_each(f: {(A!)} box) => None

  fun filter(f: {(A!): Bool} box): List[A] => this

  fun fold[B: Any val](f: {(B!, A!): B^} box, acc: B): B => acc

  fun every(f: {(A!): Bool} box): Bool => true

  fun exists(f: {(A!): Bool} box): Bool => false

  fun partition(f: {(A!): Bool} box): (List[A], List[A]) =>
    (this, this)

  fun drop(n: U64): List[A] => this

  fun drop_while(f: {(A!): Bool} box): List[A] => this

  fun take(n: U64): List[A] => this

  fun take_while(f: {(A!): Bool} box): List[A] => this

class val Cons[A: Any val]
  let _size: U64
  let _head: A
  let _tail: List[A] val

  new val create(a: A, t: List[A]) =>
    _head = consume a
    _tail = consume t
    _size = 1 + _tail.size()

  fun size(): U64 => _size

  fun is_empty(): Bool => false

  fun is_non_empty(): Bool => true

  fun head(): A => _head

  fun tail(): List[A] => _tail

  fun val reverse(): List[A] =>
    _reverse(this, Nil[A])

  fun val _reverse(l: List[A], acc: List[A]): List[A] =>
    match l
    | let cons: Cons[A] => _reverse(cons.tail(), acc.prepend(cons.head()))
    else
      acc
    end

  fun val prepend(a: A): List[A] => Cons[A](consume a, this)

  fun val concat(l: List[A]): List[A] => _concat(l, this.reverse())

  fun val _concat(l: List[A], acc: List[A]): List[A] =>
    match l
    | let cons: Cons[A] => _concat(cons.tail(), acc.prepend(cons.head()))
    else
      acc.reverse()
    end

  fun val map[B: Any val](f: {(A!): B^} box): List[B] =>
    _map[B](this, f, Nil[B])

  fun _map[B: Any val](l: List[A], f: {(A!): B^} box, acc: List[B]): List[B] =>
    match l
    | let cons: Cons[A] => _map[B](cons.tail(), f, acc.prepend(f(cons.head())))
    else
      acc.reverse()
    end

  fun val flat_map[B: Any val](f: {(A!): List[B]} box): List[B] =>
    _flat_map[B](this, f, Nil[B])

  fun _flat_map[B: Any val](l: List[A], f: {(A!): List[B]} box, acc: List[B]): List[B] =>
    match l
    | let cons: Cons[A] => _flat_map[B](cons.tail(), f, Lists._rev_prepend[B](f(cons.head()), acc))
    else
      acc.reverse()
    end

  fun val for_each(f: {(A!)} box) =>
    _for_each(this, f)

  fun _for_each(l: List[A], f: {(A!)} box) =>
    match l
    | let cons: Cons[A] =>
      f(cons.head())
      _for_each(cons.tail(), f)
    end

  fun val filter(f: {(A!): Bool} box): List[A] =>
    _filter(this, f, Nil[A])

  fun _filter(l: List[A], f: {(A!): Bool} box, acc: List[A]): List[A] =>
    match l
    | let cons: Cons[A] =>
      if (f(cons.head())) then
        _filter(cons.tail(), f, acc.prepend(cons.head()))
      else
        _filter(cons.tail(), f, acc)
      end
    else
      acc.reverse()
    end

  fun val fold[B: Any val](f: {(B!, A!): B^} box, acc: B): B =>
    _fold[B](this, f, acc)

  fun _fold[B: Any val](l: List[A], f: {(B!, A!): B^} box, acc: B): B =>
    match l
    | let cons: Cons[A] =>
      _fold[B](cons.tail(), f, f(acc, cons.head()))
    else
      acc
    end

  fun val every(f: {(A!): Bool} box): Bool =>
    _every(this, f)

  fun _every(l: List[A], f: {(A!): Bool} box): Bool =>
    match l
    | let cons: Cons[A] =>
      if (f(cons.head())) then
        _every(cons.tail(), f)
      else
        false
      end
    else
      true
    end

  fun val exists(f: {(A!): Bool} box): Bool =>
    _exists(this, f)

  fun _exists(l: List[A], f: {(A!): Bool} box): Bool =>
    match l
    | let cons: Cons[A] =>
      if (f(cons.head())) then
        true
      else
        _exists(cons.tail(), f)
      end
    else
      false
    end

  fun val partition(f: {(A!): Bool} box): (List[A], List[A]) =>
    var hits: List[A] = Nil[A]
    var misses: List[A] = Nil[A]
    var cur: List[A] = this
    while(true) do
      match cur
      | let cons: Cons[A] =>
        let next = cons.head()
        if (f(next)) then hits = hits.prepend(next) else misses = misses.prepend(next) end
        cur = cons.tail()
      else
        break
      end
    end
    (hits.reverse(), misses.reverse())

  fun val drop(n: U64): List[A] =>
    var cur: List[A] = this
    if cur.size() <= n then return Nil[A] end
    var count = n
    while(count > 0) do
      match cur
      | let cons: Cons[A] =>
        cur = cons.tail()
        count = count - 1
      end
    end
    cur

  fun val drop_while(f: {(A!): Bool} box): List[A] =>
    var cur: List[A] = this
    while(true) do
      match cur
      | let cons: Cons[A] =>
        if f(cons.head()) then cur = cons.tail() else break end
      else
        return Nil[A]
      end
    end
    cur

  fun val take(n: U64): List[A] =>
    var cur: List[A] = this
    if cur.size() <= n then return cur end
    var count = n
    var res: List[A] = Nil[A]
    while(count > 0) do
      match cur
      | let cons: Cons[A] =>
        res = res.prepend(cons.head())
        cur = cons.tail()
      else
        return res.reverse()
      end
      count = count - 1
    end
    res.reverse()

  fun val take_while(f: {(A!): Bool} box): List[A] =>
    var cur: List[A] = this
    var res: List[A] = Nil[A]
    while(true) do
      match cur
      | let cons: Cons[A] =>
        if f(cons.head()) then
          res = res.prepend(cons.head())
          cur = cons.tail()
        else
          break
        end
      else
        return res.reverse()
      end
    end
    res.reverse()

primitive Lists
  fun val empty[T: Any val](): List[T] => Nil[T]

  fun val cons[T: Any val](a: T, t: List[T]): List[T] => Cons[T](consume a, t)

  fun val apply[T: Any val](arr: Array[T]): List[T] =>
    var lst = this.empty[T]()
    for v in arr.values() do
      lst = lst.prepend(v)
    end
    lst.reverse()

  fun val flatten[T: Any val](l: List[List[T]]): List[T] => _flatten[T](l, Nil[T])

  fun val _flatten[T: Any val](l: List[List[T]], acc: List[T]): List[T] =>
    match l
    | let cns: Cons[List[T]] =>
      _flatten[T](cns.tail(), _rev_prepend[T](cns.head(), acc))
    else
      acc.reverse()
    end

  fun val _rev_prepend[T: Any val](l: List[T], target_l: List[T]): List[T] =>
    // Prepends l in reverse order onto target
    match l
    | let cns: Cons[T] =>
      _rev_prepend[T](cns.tail(), target_l.prepend(cns.head()))
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
