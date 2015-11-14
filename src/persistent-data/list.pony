trait val List[A: Any val]
  fun size(): U64
  fun head(): this->A ?
  fun tail(): this->List[A] ?
  fun val prepend(a: A): this->List[A]^ ?

class val LNil[A: Any val] is List[A]
  new create() => this

  fun size(): U64 => 0
  fun head(): this->A ? => error
  fun tail(): this->List[A] ? => error
  fun val prepend(a: A): this->List[A]^ ? =>
    LCons[A](consume a, recover val LNil[A] end) as List[A]

class val LCons[A: Any val] is List[A]
  let _size: U64
  let _head: A
  let _tail: List[A]

  new val create(a: A, t: List[A]) =>
    _head = consume a
    _tail = consume t
    _size = 1 + _tail.size()

  fun size(): U64 => _size
  fun head(): this->A => _head
  fun tail(): this->List[A] ? => _tail as this->List[A]
  fun val prepend(a: A): this->List[A]^ ? =>
    LCons[A](consume a, this) as List[A]

primitive ListT
  fun val empty[A: Any val](): List[A] => recover val LNil[A] end
  fun val cons[A: Any val](a: A, t: List[A]): List[A] => LCons[A](consume a, t)