use "debug"

trait val Map[V: Any val]
  fun size(): U64
  fun _is_leaf(): Bool
  fun apply(k: String): (V | None) ? => get(k)
  fun get(k: String): (V | None) ?
//  fun getOption(k: String): Option[V] ? =>
//      let res = get(k)
//      if (res == None) then ONone[V] else OSome[V](res) end
  fun _getWithHash(k: String, hash: U32, level: U32): (V | None) ?
  fun put(k: String, v: V): Map[V] ?
  fun _putWithHash(k: String, v: V, hash: U32, level: U32): Map[V] ?

primitive Maps
  fun val empty[V: Any val](): Map[V] => MapNode[V].empty()
  fun val from[V: Any val](pairs: Array[(String, V)]): Map[V] ? =>
    var newMap = empty[V]()
    var count: U64 = 0
    while(count < pairs.size()) do
      (let k, let v) = pairs(count)
      newMap = newMap.put(k, v)
      count = count + 1
    end
    newMap
  fun _last_level(): U32 => 4

class val LeafNode[V: Any val] is Map[V]
  let _key: String
  let _value: V

  new val create(k: String, v: V) =>
    _key = k
    _value = v

  fun size(): U64 => 1

  fun _is_leaf(): Bool => true

  fun get(k: String): (V | None) =>
    if (k == _key) then _value else None end

  fun getOption(k: String): Option[V] =>
    if (k == _key) then OSome[V](_value) else ONone[V] end

  fun _getWithHash(k: String, hash: U32, level: U32): (V | None) => get(k)

  fun put(k: String, v: V): Map[V] ? =>
    if (k == _key) then
      LeafNode[V](k, v) as Map[V]
    else
      let tempNode = MapNode[V].empty().put(_key, _value)
      tempNode.put(k, v)
    end

  fun _putWithHash(k: String, v: V, hash: U32, level: U32): Map[V] ? =>
    if (k == _key) then
      LeafNode[V](k, v) as Map[V]
    else
      let tempNode = MapNode[V].empty()._putWithHash(_key, _value, hash, level + 1)
      tempNode._putWithHash(k, v, hash, level + 1)
    end

class val Entry[V: Any val]
  let key: String
  let value: V

  new val create(k: String, v: V) =>
    key = k
    value = v


class val MultiLeafNode[V: Any val] is Map[V]
  let _entries: List[Entry[V]]

  new val create(es: List[Entry[V]]) =>
    _entries = es

  fun size(): U64 => _entries.size()

  fun _is_leaf(): Bool => true

  fun get(k: String): (V | None) =>
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

  fun _getWithHash(k: String, hash: U32, level: U32): (V | None) => get(k)

  fun put(k: String, v: V): Map[V] =>
    let test =
      object
        let key: String = k
        fun apply(e: Entry[V]): Bool => e.key == key
      end

    if (_entries.exists(test)) then
      _updateEntry(k, v, _entries, Lists.empty[Entry[V]]())
    else
      MultiLeafNode[V](_entries.prepend(Entry[V](k, v)))
    end

  fun _updateEntry(k: String, v: V, es: List[Entry[V]], acc: List[Entry[V]]): Map[V] =>
    try
      let next = es.head()
      if (next.key == k) then
        let newEntry = Entry[V](k, v)
        let newEntries = acc.prepend(newEntry).reverse().concat(es.tail())
        MultiLeafNode[V](newEntries)
      else
        _updateEntry(k, v, es.tail(), acc.prepend(next))
      end
    else
      let newEntries = acc.reverse()
      MultiLeafNode[V](newEntries)
    end

  fun _putWithHash(k: String, v: V, hash: U32, level: U32): Map[V] => put(k, v)

class val MapNode[V: Any val] is Map[V]
  let _size: U64
  //Currently, 32-bit bitmap
  let _bitmap: U32
  let _pointers: Array[Map[V]] val

  new val create(bmap: U32, ps: Array[Map[V]] val) ? =>
    _bitmap = bmap
    _pointers = ps
    _size = MapHelpers.sumArraySizes[V](_pointers)

  new val empty() =>
    _bitmap = 0
    _pointers = recover val Array[Map[V]] end
    _size = 0

  fun size(): U64 => _size

  fun _is_leaf(): Bool => false

  fun get(k: String): (V | None) ? =>
    let hash = _hash(k)
    let level: U32 = 0
    _getWithHash(k, hash, level)

  fun _getWithHash(k: String, hash: U32, level: U32): (V | None) ? =>
    //if level is greater than (32 / 5) then rehash
    let bmapIdx = _BitOps.bitmapIdxFor(hash, level)
    if (_BitOps.checkIdxBit(_bitmap, bmapIdx)) then
      let arrayIdx = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
      _pointers(arrayIdx)._getWithHash(k, hash, level + 1)
    else
      None
    end

  fun put(k: String, v: V): Map[V] ? =>
    let hash = _hash(k)
    let level: U32 = 0
    _putWithHash(k, v, hash, level)

  fun _putWithHash(k: String, v: V, hash: U32, level: U32): Map[V] ? =>
    if (level >= Maps._last_level()) then return _lastLevelPutWithHash(k, v, hash) end
    let bmapIdx = _BitOps.bitmapIdxFor(hash, level)
    let arrayIdx: U64 = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
    if (_BitOps.checkIdxBit(_bitmap, bmapIdx)) then
      let newNode = _pointers(arrayIdx)._putWithHash(k, v, hash, level + 1)
      let newArray = _overwriteInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[V](_bitmap, newArray)
    else
      let newBitMap = _BitOps.flipIndexedBitOn(_bitmap, bmapIdx)
      let newNode = LeafNode[V](k, v)
      let newArray = _insertInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[V](newBitMap, newArray)
    end

  fun _lastLevelPutWithHash(k: String, v: V, hash: U32): Map[V] ? =>
    let bmapIdx = _BitOps.bitmapIdxFor(hash, Maps._last_level())
    let arrayIdx: U64 = _BitOps.arrayIdxFor(_bitmap, bmapIdx)
    if (_BitOps.checkIdxBit(_bitmap, bmapIdx)) then
      let newNode = _pointers(arrayIdx).put(k, v)
      let newArray = _overwriteInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[V](_bitmap, newArray)
    else
      let newBitMap = _BitOps.flipIndexedBitOn(_bitmap, bmapIdx)
      let newEntry = Entry[V](k, v)
      let newNode = MultiLeafNode[V](Lists.from[Entry[V]]([newEntry]))
      let newArray = _insertInArrayAt(_pointers, newNode, arrayIdx)
      MapNode[V](newBitMap, newArray)
    end

  fun _hash(k: String): U32 => k.hash().u32()

  fun _insertInArrayAt(arr: Array[Map[V]] val, node: Map[V], idx: U64): Array[Map[V]] val ? =>
    var belowArr: U64 = 0
    var aboveArr = idx
    let newArray: Array[Map[V]] trn = recover trn Array[Map[V]] end
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

  fun _overwriteInArrayAt(arr: Array[Map[V]] val, node: Map[V], idx: U64): Array[Map[V]] val ? =>
    var belowArr: U64 = 0
    var aboveArr = idx + 1
    let newArray: Array[Map[V]] trn = recover trn Array[Map[V]] end
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

  fun arrayIdxFor(bmap: U32, idx: U32): U64 =>
   // Using 0xFFFFFFFF to generate mask
   let mask = not(4294967295 << idx)
    (countPop(mask and bmap)).u64()

  fun flipIndexedBitOn(bmap: U32, idx: U32): U32 => (1 << idx) or bmap

primitive MapHelpers
  fun sumArraySizes[V: Any val](arr: Array[Map[V]] val): U64 ? =>
    var count: U64 = 0
    var sum: U64 = 0
    while (count < arr.size()) do
      sum = sum + arr(count).size()
      count = count + 1
    end
    sum