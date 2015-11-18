use "../function-types"

trait val Option[V: Any val]
  fun is_empty(): Bool
  fun value(): V ?
  fun map[B: Any val](f: Fn1[V!,B^]): Option[B] ?
  fun flat_map[B: Any val](f: Fn1[V!,Option[B]]): Option[B] ?
  fun val filter(f: Fn1[V!,Bool]): Option[V] ?

class val ONone[V: Any val] is Option[V]
  fun is_empty(): Bool => true

  fun value(): V ? => error

  fun map[B: Any val](f: Fn1[V!,B^]): Option[B] => ONone[B]

  fun flat_map[B: Any val](f: Fn1[V!,Option[B]]): Option[B] => ONone[B]

  fun val filter(f: Fn1[V!,Bool]): Option[V] => ONone[V]

class val OSome[V: Any val] is Option[V]
  let _value: V

  new val create(v: V) =>
    _value = consume v

  fun is_empty(): Bool => false

  fun value(): V => _value

  fun map[B: Any val](f: Fn1[V,B^]): Option[B] ? => OSome[B](f(_value))

  fun flat_map[B: Any val](f: Fn1[V,Option[B]]): Option[B] ? => f(_value)

  fun val filter(f: Fn1[V!,Bool]): Option[V] ? =>
    if (f(_value)) then recover val OSome[V](_value) end else recover val ONone[V] end end


