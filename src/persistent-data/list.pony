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

//  fun string(): String

class val LNil[A: Any val] is List[A]
  new create() => this

  fun size(): U64 => 0
  fun is_empty(): Bool => true
  fun head(): this->A ? => error
  fun tail(): this->List[A] ? => error
  fun val reverse(): this->List[A] => recover val LNil[A] end
  fun val prepend(a: A): this->List[A]^ ? =>
    LCons[A](consume a, recover val LNil[A] end) as List[A]
  fun val concat(l: List[A]): this->List[A]^ => l
  fun map[B: Any val](f: Fn1[A!,B^]): this->List[B]^ => recover val LNil[B] end
  fun flatMap[B: Any val](f: Fn1[A!,List[B]]): this->List[B]^ => recover val LNil[B] end
  fun filter(f: Fn1[A!, Bool]): List[A] => recover val LNil[A] end
  fun fold[B: Any val](f: Fn2[B!,A!,B^], acc: B): B => acc
  fun string(): String => "List()"

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
    let first = f(this.head())
    _map[B](this.tail(), f, ListT.from[B]([first]))
  fun _map[B: Any val](l: List[A], f: Fn1[A!,B^], acc: List[B]): this->List[B]^ ? =>
    if (l.is_empty()) then return acc.reverse() end
    _map[B](l.tail(), f, acc.prepend(f(l.head())))
  fun flatMap[B: Any val](f: Fn1[A!,List[B]]): this->List[B]^ ? =>
    let first = f(this.head())
    let firstLst = ListT._rev_prepend[B](first, recover val LNil[B] end)
    _flatMap[B](this.tail(), f, firstLst)
  fun _flatMap[B: Any val](l: List[A], f: Fn1[A!,List[B]], acc: List[B]): this->List[B]^ ? =>
    if (l.is_empty()) then return acc.reverse() end
    _flatMap[B](l.tail(), f, ListT._rev_prepend[B](f(l.head()), acc))
  fun filter(f: Fn1[A!, Bool]): List[A] ? =>
    if (f(this.head())) then
      _filter(this.tail(), f, ListT.from[A]([this.head()]))
    else
      _filter(this.tail(), f, ListT.empty[A]())
    end
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

primitive ListT
  fun val empty[A: Any val](): List[A] => recover val LNil[A] end
  fun val cons[A: Any val](a: A, t: List[A]): List[A] => LCons[A](consume a, t)

  fun val from[A: Any val](arr: Array[A]): List[A] ? =>
    var lst = this.empty[A]()
    for v in arr.values() do
      lst = lst.prepend(v)
    end
    lst.reverse()

  fun val reverse[A: Any val](l: List[A]): List[A] ? => _reverse[A](l, recover val LNil[A] end)
  fun val _reverse[A: Any val](l: List[A], acc: List[A]): List[A] ? =>
    if l.is_empty() then
      acc
    else
      _reverse[A](l.tail(), acc.prepend(l.head()))
    end

  fun val flatten[A: Any val](l: List[List[A]]): List[A] ? => _flatten[A](l, recover val LNil[A] end)
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
