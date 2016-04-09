type List[A] is (Cons[A] | Nil[A])

primitive Lists[A]
  fun val empty(): List[A] => Nil[A]

  fun val cons(a: val->A, t: List[A]): List[A] => Cons[A](consume a, t)

  fun val apply(arr: Array[val->A]): List[A] =>
    var lst = this.empty()
    for v in arr.values() do
      lst = lst.prepend(v)
    end
    lst.reverse()

  fun val _rev_prepend[B](l: List[B], target: List[B]): List[B] =>
    // Prepends l in reverse order onto target
    match l
    | let cns: Cons[B] =>
      _rev_prepend[B](cns.tail(), target.prepend(cns.head()))
    else
      target
    end



  fun eq[T: Equatable[T] val = A](l1: List[T], l2: List[T]): Bool ? =>
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

primitive Nil[A]
  fun size(): U64 => 0
  fun is_empty(): Bool => true
  fun is_non_empty(): Bool => false
  fun head(): val->A ? => error
  fun tail(): List[A] ? => error
  fun reverse(): Nil[A] => this
  fun prepend(a: val->A!): Cons[A] => Cons[A](consume a, this)
  fun concat(l: List[A]): List[A] => l
  fun map[B](f: {(val->A): val->B} box): Nil[B] => Nil[B]
  fun flat_map[B](f: {(val->A): List[B]} box): Nil[B] => Nil[B]
  fun for_each(f: {(val->A)} box) => None
  fun filter(f: {(val->A): Bool} box): Nil[A] => this
  fun fold[B](f: {(B, val->A): B^} box, acc: B): B => consume acc
  fun every(f: {(val->A): Bool} box): Bool => true
  fun exists(f: {(val->A): Bool} box): Bool => false
  fun partition(f: {(val->A): Bool} box): (Nil[A], Nil[A]) =>
    (this, this)
  fun drop(n: U64): Nil[A] => this
  fun drop_while(f: {(val->A): Bool} box): Nil[A] => this
  fun take(n: U64): Nil[A] => this
  fun take_while(f: {(val->A): Bool} box): Nil[A] => this

class val Cons[A]
  let _size: U64
  let _head: val->A
  let _tail: List[A] val

  new val create(a: val->A, t: List[A]) =>
    _head = consume a
    _tail = consume t
    _size = 1 + _tail.size()

  fun size(): U64 => _size
  fun is_empty(): Bool => false
  fun is_non_empty(): Bool => true
  fun head(): val->A => _head
  fun tail(): List[A] => _tail

  fun val reverse(): List[A] =>
    _reverse(this, Nil[A])

  fun val _reverse(l: List[A], acc: List[A]): List[A] =>
    match l
    | let cons: Cons[A] => _reverse(cons.tail(), acc.prepend(cons.head()))
    else
      acc
    end

  fun val prepend(a: val->A!): Cons[A] => Cons[A](consume a, this)

  fun val concat(l: List[A]): List[A] => _concat(l, this.reverse())

  fun val _concat(l: List[A], acc: List[A]): List[A] =>
    match l
    | let cons: Cons[A] => _concat(cons.tail(), acc.prepend(cons.head()))
    else
      acc.reverse()
    end

  fun val map[B](f: {(val->A): val->B} box): List[B] =>
    _map[B](this, f, Nil[B])

  fun _map[B](l: List[A], f: {(val->A): val->B} box, acc: List[B]): List[B] =>
    match l
    | let cons: Cons[A] => _map[B](cons.tail(), f, acc.prepend(f(cons.head())))
    else
      acc.reverse()
    end

  fun val flat_map[B](f: {(val->A): List[B]} box): List[B] =>
    _flat_map[B](this, f, Nil[B])

  fun _flat_map[B](l: List[A], f: {(val->A): List[B]} box, acc: List[B]): List[B] =>
    match l
    | let cons: Cons[A] => _flat_map[B](cons.tail(), f, _rev_prepend[B](f(cons.head()), acc))
    else
      acc.reverse()
    end

  fun tag _rev_prepend[B](l: List[B], target: List[B]): List[B] =>
    // Prepends l in reverse order onto target
    match l
    | let cns: Cons[B] =>
      _rev_prepend[B](cns.tail(), target.prepend(cns.head()))
    else
      target
    end

//  fun val flatten[B](): List[B] ? =>
//    match (_head, _tail)
//    | (let h: List[B], let t: List[List[B]]) => _flatten[B](Cons[List[B]](h, t), Nil[B])
//    else
//      error
//    end
//
//  fun val _flatten[B](l: List[List[B]], acc: List[B]): List[B] =>
//    match l
//    | let cns: Cons[List[B]] =>
//      _flatten(cns.tail(), _rev_prepend[B](cns.head(), acc))
//    else
//      acc.reverse()
//    end

  fun val for_each(f: {(val->A)} box) =>
    _for_each(this, f)

  fun _for_each(l: List[A], f: {(val->A)} box) =>
    match l
    | let cons: Cons[A] =>
      f(cons.head())
      _for_each(cons.tail(), f)
    end

  fun val filter(f: {(val->A): Bool} box): List[A] =>
    _filter(this, f, Nil[A])

  fun _filter(l: List[A], f: {(val->A): Bool} box, acc: List[A]): List[A] =>
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

  fun val fold[B](f: {(B, val->A): B^} box, acc: B): B =>
    _fold[B](this, f, consume acc)

  fun val _fold[B](l: List[A], f: {(B, val->A): B^} box, acc: B): B =>
    match l
    | let cons: Cons[A] =>
      _fold[B](cons.tail(), f, f(consume acc, cons.head()))
    else
      acc
    end

  fun val every(f: {(val->A): Bool} box): Bool =>
    _every(this, f)

  fun _every(l: List[A], f: {(val->A): Bool} box): Bool =>
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

  fun val exists(f: {(val->A): Bool} box): Bool =>
    _exists(this, f)

  fun _exists(l: List[A], f: {(val->A): Bool} box): Bool =>
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

  fun val partition(f: {(val->A): Bool} box): (List[A], List[A]) =>
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

  fun val drop_while(f: {(val->A): Bool} box): List[A] =>
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

  fun val take_while(f: {(val->A): Bool} box): List[A] =>
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
