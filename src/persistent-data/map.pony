interface Hashable
  """
  Anything with a hash method is hashable.
  """
  fun hash(): U64


//type Map[K: (Hashable val & Equatable[K] val), V: Any val] is (LeafNode[K,V] | MultiLeafNode[K,V] | MapNode[K,V])

trait val Map[K: (Hashable val & Equatable[K] val), V: Any val]
  fun size(): U64
  fun _is_leaf(): Bool
  fun apply(k: K): V ? => get(k)
  fun get(k: K): V ?
  fun _getWithHash(k: K, hash: U32, level: U32): V ?
  fun getOrElse(k: K, alt: V): V ? =>
    try
      get(k)
    else
      alt
    end
  fun put(k: K, v: V): Map[K,V] ?
  fun _putWithHash(k: K, v: V, hash: U32, level: U32): Map[K,V] ?
  fun contains(k: K): Bool =>
    try
      get(k)
      true
    else
      false
    end
  fun remove(k: K): Map[K,V] ?
  fun _removeWithHash(k: K, hash: U32, level: U32): Map[K,V] ?

primitive Maps
  fun val empty[K: (Hashable val & Equatable[K] val),V: Any val](): Map[K,V] => MapNode[K,V].empty()

  fun val from[K: (Hashable val & Equatable[K] val),V: Any val](pairs: Array[(K, V)]): Map[K,V] ? =>
    var newMap = empty[K,V]()
    for pair in pairs.values() do
      (let k, let v) = pair
      newMap = newMap.put(k, v)
    end
    newMap

  fun _last_level(): U32 => 4

class val LeafNode[K: (Hashable val & Equatable[K] val),V: Any val] is Map[K,V]
  let _key: K
  let _value: V

  new val create(k: K, v: V) =>
    _key = k
    _value = v

  fun size(): U64 => 1

  fun _is_leaf(): Bool => true

  fun get(k: K): V ? =>
    if k == _key then _value else error end

  fun _getWithHash(k: K, hash: U32, level: U32): V ? =>
    get(k)

  fun put(k: K, v: V): Map[K,V] ? =>
    if k == _key then
      LeafNode[K,V](k, v) as Map[K,V]
    else
      let mapNode = MapNode[K,V].empty().put(_key, _value)
      mapNode.put(k, v)
    end

  fun _putWithHash(k: K, v: V, hash: U32, level: U32): Map[K,V] ? =>
    if k == _key then
      LeafNode[K,V](k, v) as Map[K,V]
    else
      let mapNode = MapNode[K,V].empty()._putWithHash(_key, _value, MapHelpers._hash[K](_key), level)
      mapNode._putWithHash(k, v, hash, level)
    end

  fun remove(k: K): Map[K,V] ? => error

  fun _removeWithHash(k: K, hash: U32, level: U32): Map[K,V] ? => error

class val Entry[K: (Hashable val & Equatable[K] val),V: Any val]
  let key: K
  let value: V

  new val create(k: K, v: V) =>
    key = k
    value = v

class val MultiLeafNode[K: (Hashable val & Equatable[K] val),V: Any val] is Map[K,V]
  let _entries: List[Entry[K,V]]

  new val create() =>
    _entries = Lists[Entry[K,V]].empty()

  new val from(es: List[Entry[K,V]]) =>
    _entries = es

  fun size(): U64 => _entries.size()

  fun _is_leaf(): Bool => true

  fun get(k: K): V ? =>
    try
      var cur = _entries
      while(cur.is_non_empty()) do
        let next = cur.head()
        if (next.key == k) then return next.value end
        cur = cur.tail()
      end
      error
    else
      error
    end

  fun _getWithHash(k: K, hash: U32, level: U32): V ? => get(k)

  fun put(k: K, v: V): Map[K,V] =>
    let test =
      object
        let key: K = k
        fun apply(e: Entry[K,V]): Bool => e.key == key
      end

    if _entries.exists(test) then
      _updateEntry(k, v, _entries, Lists[Entry[K,V]].empty())
    else
      let newEntries = _entries.prepend(Entry[K,V](k,v))
      MultiLeafNode[K,V].from(newEntries)
    end

  fun _putWithHash(k: K, v: V, hash: U32, level: U32): Map[K,V] => put(k, v)

  fun _updateEntry(k: K, v: V, es: List[Entry[K,V]], acc: List[Entry[K,V]]): Map[K,V] =>
    try
      let next = es.head()
      if next.key == k then
        let newEntry = Entry[K,V](k, v)
        let newEntries = acc.prepend(newEntry).concat(es.tail())
        MultiLeafNode[K,V].from(newEntries)
      else
        _updateEntry(k, v, es.tail(), acc.prepend(next))
      end
    else
      MultiLeafNode[K,V].from(acc)
    end

  fun _removeEntry(k: K, es: List[Entry[K,V]], acc: List[Entry[K,V]]): Map[K,V] =>
    try
      let next = es.head()
      if next.key == k then
        let newEntries = acc.concat(es.tail())
        MultiLeafNode[K,V].from(newEntries)
      else
        _removeEntry(k, es.tail(), acc.prepend(next))
      end
    else
      MultiLeafNode[K,V].from(acc)
    end

  fun remove(k: K): Map[K,V] => _removeEntry(k, _entries, Lists[Entry[K,V]].empty())

  fun _removeWithHash(k: K, hash: U32, level: U32): Map[K,V] => remove(k)

class val MapNode[K: (Hashable val & Equatable[K] val),V: Any val] is Map[K,V]
  let _size: U64
  //Currently, 32-bit bitmap
  let _bitmap: U32
  let _pointers: Array[Map[K,V]] val

  new val create(bmap: U32, ps: Array[Map[K,V]] val) =>
    _bitmap = bmap
    _pointers = ps
    _size = MapHelpers.sumArraySizes[K,V](_pointers)

  new val empty() =>
    _bitmap = 0
    _pointers = recover val Array[Map[K,V]] end
    _size = 0

  fun size(): U64 => _size

  fun _is_leaf(): Bool => false

  fun get(k: K): V ? =>
    let hash = MapHelpers._hash[K](k)
    let level: U32 = 0
    _getWithHash(k, hash, level)

  fun _getWithHash(k: K, hash: U32, level: U32): V ? =>
    let bmapIdx = _BitOps.bitmapIdxFor(hash, level)
    if _BitOps.checkIdxBit(_bitmap, bmapIdx) then
      let arrayIdx = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
      _pointers(arrayIdx)._getWithHash(k, hash, level + 1)
    else
      error
    end

  fun put(k: K, v: V): Map[K,V] ? =>
    let hash = MapHelpers._hash[K](k)
    let level: U32 = 0
    _putWithHash(k, v, hash, level)

  fun _putWithHash(k: K, v: V, hash: U32, level: U32): Map[K,V] ? =>
    if (level >= Maps._last_level()) then return _lastLevelPutWithHash(k, v, hash) end
    let bmapIdx = _BitOps.bitmapIdxFor(hash, level)
    let arrayIdx: USize = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
    if _BitOps.checkIdxBit(_bitmap, bmapIdx) then
      let newNode = _pointers(arrayIdx)._putWithHash(k, v, hash, level + 1)
      let newArray = _overwriteInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[K,V](_bitmap, newArray)
    else
      let newBitMap = _BitOps.flipIndexedBitOn(_bitmap, bmapIdx)
      let newNode = LeafNode[K,V](k, v)
      let newArray = _insertInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[K,V](newBitMap, newArray)
    end

  fun _lastLevelPutWithHash(k: K, v: V, hash: U32): Map[K,V] ? =>
    let bmapIdx = _BitOps.bitmapIdxFor(hash, Maps._last_level())
    let arrayIdx: USize = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
    if _BitOps.checkIdxBit(_bitmap, bmapIdx) then
      let newNode = _pointers(arrayIdx).put(k, v)
      let newArray = _overwriteInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[K,V](_bitmap, newArray)
    else
      let newBitMap = _BitOps.flipIndexedBitOn(_bitmap, bmapIdx)
      let newNode = MultiLeafNode[K,V].put(k,v)
      let newArray = _insertInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[K,V](newBitMap, newArray)
    end

  fun _insertInArrayAt(arr: Array[Map[K,V]] val, node: Map[K,V], idx: USize): Array[Map[K,V]] val ? =>
    var belowArr: USize = 0
    var aboveArr = idx
    let newArray: Array[Map[K,V]] trn = recover trn Array[Map[K,V]] end
    while(belowArr < idx) do
      newArray.push(arr(belowArr))
      belowArr = belowArr + 1
    end
    newArray.push(node)
    while(aboveArr < arr.size()) do
      newArray.push(arr(aboveArr))
      aboveArr = aboveArr + 1
    end
    newArray

  fun _overwriteInArrayAt(arr: Array[Map[K,V]] val, node: Map[K,V], idx: USize): Array[Map[K,V]] val ? =>
    var belowArr: USize = 0
    var aboveArr = idx + 1
    let newArray: Array[Map[K,V]] trn = recover trn Array[Map[K,V]] end
    while(belowArr < idx) do
      newArray.push(arr(belowArr))
      belowArr = belowArr + 1
    end
    newArray.push(node)
    while(aboveArr < arr.size()) do
      newArray.push(arr(aboveArr))
      aboveArr = aboveArr + 1
    end
    newArray

  fun _removeInArrayAt(arr: Array[Map[K,V]] val, idx: USize): Array[Map[K,V]] val ? =>
    var belowArr: USize = 0
    var aboveArr = idx + 1
    let newArray: Array[Map[K,V]] trn = recover trn Array[Map[K,V]] end
    while(belowArr < idx) do
      newArray.push(arr(belowArr))
      belowArr = belowArr + 1
    end
    while(aboveArr < arr.size()) do
      newArray.push(arr(aboveArr))
      aboveArr = aboveArr + 1
    end
    newArray

  fun remove(k: K): Map[K,V] ? =>
    if contains(k) then _removeWithHash(k, MapHelpers._hash[K](k), 0) else this as Map[K,V] end

  fun _removeWithHash(k: K, hash: U32, level: U32): Map[K,V] ? =>
    let bmapIdx = _BitOps.bitmapIdxFor(hash, level)
    let arrayIdx: USize = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
    if level >= Maps._last_level() then
      let newNode = _pointers(arrayIdx).remove(k)
      MapNode[K,V](_bitmap, _overwriteInArrayAt(_pointers, newNode, arrayIdx))
    else
      let target = _pointers(arrayIdx)
      if target._is_leaf() then
        let newBMap = _BitOps.flipIndexedBitOff(_bitmap, bmapIdx)
        let newArray = _removeInArrayAt(_pointers, arrayIdx)
        MapNode[K,V](newBMap, newArray)
      else
        let newNode = target._removeWithHash(k, hash, level + 1)
        let newArray = _overwriteInArrayAt(_pointers, newNode, arrayIdx)
        MapNode[K,V](_bitmap, newArray)
      end
    end

// For 32-bit operations
primitive _BitOps
  fun maskLow(n: U32): U32 => n and 0x1F

  fun bitmapIdxFor(hash: U32, level: U32): U32 => maskLow(hash >> (level * 5))

  fun checkIdxBit(bmap: U32, idx: U32): Bool =>
    let bit = (bmap >> idx) and 1
    if bit == 0 then false else true end

  fun arrayIdxFor(bmap: U32, idx: U32): USize =>
   let mask = not(0xFFFF_FFFF << idx)
    ((mask and bmap).popcount()).usize()

  fun flipIndexedBitOn(bmap: U32, idx: U32): U32 => (1 << idx) or bmap

  fun flipIndexedBitOff(bmap: U32, idx: U32): U32 => not(1 << idx) and bmap

primitive MapHelpers
  fun sumArraySizes[K: (Hashable val & Equatable[K] val),V: Any val](arr: Array[Map[K,V]] val): U64 =>
    var sum: U64 = 0
    for m in arr.values() do
      sum = sum + m.size()
    end
    sum

  fun _hash[K: Hashable val](k: K): U32 => k.hash().u32()
