use "debug"

interface Hashable
  """
  Anything with a hash method is hashable.
  """
  fun hash(): U64

trait val Map[K: (Hashable val & Equatable[K] val), V: Any val]
  fun size(): U64
  fun _is_leaf(): Bool
  fun apply(k: K): (V | None) ? => get(k)
  fun get(k: K): (V | None) ?
  fun getOption(k: K): Option[V] ? =>
    match get(k)
    | let r: V => OSome[V](r)
    else
      ONone[V]
    end
  fun _getWithHash(k: K, hash: U32, level: U32): (V | None) ?
  fun getOrElse(k: K, alt: V): V ? =>
    match get(k)
    | let v: V => v
    else
      alt
    end
  fun put(k: K, v: V): Map[K,V] ?
  fun _putWithHash(k: K, v: V, hash: U32, level: U32): Map[K,V] ?
  fun contains(k: K): Bool ? =>
    match get(k)
    | let v: V => true
    else
      false
    end
//  fun remove(k: K): Map[K,V] ?

primitive Maps
  fun val empty[K: (Hashable val & Equatable[K] val),V: Any val](): Map[K,V] => MapNode[K,V].empty()
  fun val from[K: (Hashable val & Equatable[K] val),V: Any val](pairs: Array[(K, V)]): Map[K,V] ? =>
    var newMap = empty[K,V]()
    var count: U64 = 0
    while(count < pairs.size()) do
      (let k, let v) = pairs(count)
      newMap = newMap.put(k, v)
      count = count + 1
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

  fun get(k: K): (V | None) =>
    if (k == _key) then _value else None end

  fun getOption(k: K): Option[V] =>
    if (k == _key) then OSome[V](_value) else ONone[V] end

  fun _getWithHash(k: K, hash: U32, level: U32): (V | None) =>
    get(k)

  fun put(k: K, v: V): Map[K,V] ? =>
    if (k == _key) then
      LeafNode[K,V](k, v) as Map[K,V]
    else
      let tempNode = MapNode[K,V].empty().put(_key, _value)
      tempNode.put(k, v)
    end

  fun _putWithHash(k: K, v: V, hash: U32, level: U32): Map[K,V] ? =>
    if (k == _key) then
      LeafNode[K,V](k, v) as Map[K,V]
    else
      let tempNode = MapNode[K,V].empty()._putWithHash(_key, _value, MapHelpers._hash[K](_key), level)
      tempNode._putWithHash(k, v, hash, level)
    end

  fun remove(k: K): Map[K,V] ? => error

class val Entry[K: (Hashable val & Equatable[K] val),V: Any val]
  let key: K
  let value: V

  new val create(k: K, v: V) =>
    key = k
    value = v


class val MultiLeafNode[K: (Hashable val & Equatable[K] val),V: Any val] is Map[K,V]
  let _entries: List[Entry[K,V]]

  new val create() =>
    _entries = Lists.empty[Entry[K,V]]()

  new val from(es: List[Entry[K,V]]) =>
    _entries = es

  fun size(): U64 => _entries.size()

  fun _is_leaf(): Bool => true

  fun get(k: K): (V | None) =>
    try
      var cur = _entries
      while(cur.is_non_empty()) do
        let next = cur.head()
        if (next.key == k) then return next.value end
        cur = cur.tail()
      end
      return None
    else
      return None
    end

  fun _getWithHash(k: K, hash: U32, level: U32): (V | None) => get(k)

  fun put(k: K, v: V): Map[K,V] ? =>
    let test =
      object
        let key: K = k
        fun apply(e: Entry[K,V]): Bool => e.key == key
      end

    if (_entries.exists(test)) then
      _updateEntry(k, v, _entries, Lists.empty[Entry[K,V]]())
    else
      let newEntries = _entries.prepend(Entry[K,V](k,v))
      MultiLeafNode[K,V].from(newEntries)
    end

  fun _updateEntry(k: K, v: V, es: List[Entry[K,V]], acc: List[Entry[K,V]]): Map[K,V] =>
    try
      let next = es.head()
      if (next.key == k) then
        let newEntry = Entry[K,V](k, v)
        let newEntries = acc.prepend(newEntry).concat(es.tail())
        MultiLeafNode[K,V].from(newEntries)
      else
        _updateEntry(k, v, es.tail(), acc.prepend(next))
      end
    else
      MultiLeafNode[K,V].from(acc)
    end

  fun _putWithHash(k: K, v: V, hash: U32, level: U32): Map[K,V] ? => put(k, v)

//  fun remove(k: K): Map[K,V] ? =>

class val MapNode[K: (Hashable val & Equatable[K] val),V: Any val] is Map[K,V]
  let _size: U64
  //Currently, 32-bit bitmap
  let _bitmap: U32
  let _pointers: Array[Map[K,V]] val

  new val create(bmap: U32, ps: Array[Map[K,V]] val) ? =>
    _bitmap = bmap
    _pointers = ps
    _size = MapHelpers.sumArraySizes[K,V](_pointers)

  new val empty() =>
    _bitmap = 0
    _pointers = recover val Array[Map[K,V]] end
    _size = 0

  fun size(): U64 => _size

  fun _is_leaf(): Bool => false

  fun get(k: K): (V | None) ? =>
    let hash = MapHelpers._hash[K](k)
    let level: U32 = 0
    _getWithHash(k, hash, level)

  fun _getWithHash(k: K, hash: U32, level: U32): (V | None) ? =>
    let bmapIdx = _BitOps.bitmapIdxFor(hash, level)
    if (_BitOps.checkIdxBit(_bitmap, bmapIdx)) then
      let arrayIdx = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
      _pointers(arrayIdx)._getWithHash(k, hash, level + 1)
    else
      None
    end

  fun put(k: K, v: V): Map[K,V] ? =>
    let hash = MapHelpers._hash[K](k)
    let level: U32 = 0
    _putWithHash(k, v, hash, level)

  fun _putWithHash(k: K, v: V, hash: U32, level: U32): Map[K,V] ? =>
    if (level >= Maps._last_level()) then return _lastLevelPutWithHash(k, v, hash) end
    let bmapIdx = _BitOps.bitmapIdxFor(hash, level)
    let arrayIdx: U64 = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
    if (_BitOps.checkIdxBit(_bitmap, bmapIdx)) then
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
    let arrayIdx: U64 = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
    if (_BitOps.checkIdxBit(_bitmap, bmapIdx)) then
      let newNode = _pointers(arrayIdx).put(k, v)
      let newArray = _overwriteInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[K,V](_bitmap, newArray)
    else
      let newBitMap = _BitOps.flipIndexedBitOn(_bitmap, bmapIdx)
      let newNode = MultiLeafNode[K,V].put(k,v)
      let newArray = _insertInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[K,V](newBitMap, newArray)
    end

  fun _insertInArrayAt(arr: Array[Map[K,V]] val, node: Map[K,V], idx: U64): Array[Map[K,V]] val ? =>
    var belowArr: U64 = 0
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
    consume newArray

  fun _overwriteInArrayAt(arr: Array[Map[K,V]] val, node: Map[K,V], idx: U64): Array[Map[K,V]] val ? =>
    var belowArr: U64 = 0
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
    consume newArray

// For 32-bit operations
primitive _BitOps
  fun maskLow(n: U32): U32 => n and 31

  fun bitmapIdxFor(hash: U32, level: U32): U32 => maskLow(hash >> (level * 5))

  fun checkIdxBit(bmap: U32, idx: U32): Bool =>
    let bit = (bmap >> idx) and 1
    if (bit == 0) then false else true end

  fun countPop(n: U32): U32 => @"llvm.ctpop.i32"[U32](n)

//  fun countPop(n: U32): U32 =>
//    //0x55555555
//    let sk5: U32 = 1431655765
//    //0x33333333
//    let sk3: U32 = 858993459
//    //0xF0F0F0F
//    let skF0: U32 = 252645135
//    //0xFF00FF
//    let skFF: U32 = 16711935
//    var ct = n
//    ct = ct - ((ct >> 1) and sk5)
//    ct = (ct and sk3) + ((ct >> 2) and sk3)
//    ct = (ct and skF0) + ((ct >> 4) and skF0)
//    ct = ct + (ct >> 8)
//    ct = (ct + (ct >> 16)) and 63 //63 -> 0x3F
//    ct

  fun arrayIdxFor(bmap: U32, idx: U32): U64 =>
   // Using 0xFFFFFFFF to generate mask
   let mask = not(4294967295 << idx)
    (countPop(mask and bmap)).u64()

  fun flipIndexedBitOn(bmap: U32, idx: U32): U32 => (1 << idx) or bmap

primitive MapHelpers
  fun sumArraySizes[K: (Hashable val & Equatable[K] val),V: Any val](arr: Array[Map[K,V]] val): U64 ? =>
    var count: U64 = 0
    var sum: U64 = 0
    while (count < arr.size()) do
      sum = sum + arr(count).size()
      count = count + 1
    end
    sum

  fun _hash[K: Hashable val](k: K): U32 => k.hash().u32()
