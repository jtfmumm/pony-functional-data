use "../"
use mut = "collections"
use "time"
use "debug"
use "random"


primitive Bench
  fun bench(iterations: USize, keys: U64) ? =>
    var pMap: Map[String,U64] = Maps.empty[String,U64]()
    let mMap: mut.Map[String,U64] = mut.Map[String,U64]()
    let kvs = Array[(String,U64)]()
    // Different seed each run
    let dice = Dice(MT(Time.millis()))
    var count: USize = 0
    var perf_begin: U64 = 0
    var perf_end: U64 = 0

    while(count < iterations) do
      let k0 = dice(1,keys).string()
      let k: String val = consume k0
      let v = dice(1,100000)
      kvs.push((k, v))
      count = count + 1
    end

    //WRITES
    count = 0
    Time.perf_begin()
    perf_begin = Time.millis()
    while(count < iterations) do
      let k = kvs(count)._1
      let v = kvs(count)._2
      pMap = pMap.update(k, v)
      count = count + 1
    end
    perf_end = Time.millis()
    Time.perf_end()
    Debug.out("Persistent writes: " + (perf_end - perf_begin).string())

    count = 0
    Time.perf_begin()
    perf_begin = Time.millis()
    while(count < iterations) do
      let k = kvs(count)._1
      let v = kvs(count)._2
      mMap.update(k, v)
      count = count + 1
    end
    perf_end = Time.millis()
    Time.perf_end()
    Debug.out("Mutable writes: " + (perf_end - perf_begin).string())


    //READS
    count = 0
    Time.perf_begin()
    perf_begin = Time.millis()
    while(count < iterations) do
      let pmv = pMap(kvs(count)._1)
      count = count + 1
    end
    perf_end = Time.millis()
    Time.perf_end()
    Debug.out("Persistent reads: " + (perf_end - perf_begin).string())

    count = 0
    Time.perf_begin()
    perf_begin = Time.millis()
    while(count < iterations) do
      let mmv = mMap(kvs(count)._1)
      count = count + 1
    end
    perf_end = Time.millis()
    Time.perf_end()
    Debug.out("Mutable reads: " + (perf_end - perf_begin).string())

//fun list_try_bench(iterations: USize) =>
//    // Different seed each run
//    let dice = Dice(MT(Time.millis()))
//    var count: USize = 0
//    var long_lst: List[U64] = Lists.empty[U64]()
//    var short_lst: List[U64] = Lists.empty[U64]().prepend(1).prepend(2).prepend(3).prepend(4)
//    var perf_begin: U64 = 0
//    var perf_end: U64 = 0
//
//    while(count < iterations) do
//      let v: U64 = dice(1,100000)
//      long_lst = long_lst.prepend(v)
//      count = count + 1
//    end
//
//    //MAPS
//    count = 0
//    Time.perf_begin()
//    perf_begin = Time.millis()
//    while(count < iterations) do
//      let new_m = long_lst.map[U64](lambda(x: U64): U64 => x * 2 end)
//      count = count + 1
//    end
//    perf_end = Time.millis()
//    Time.perf_end()
//    Debug.out("Match map (LONG): " + (perf_end - perf_begin).string())
//
//    count = 0
//    Time.perf_begin()
//    perf_begin = Time.millis()
//    while(count < iterations) do
//      let new_m = long_lst.map_try[U64](lambda(x: U64): U64 => x * 2 end)
//      count = count + 1
//    end
//    perf_end = Time.millis()
//    Time.perf_end()
//    Debug.out("Try map (LONG): " + (perf_end - perf_begin).string())
//
//    count = 0
//    Time.perf_begin()
//    perf_begin = Time.millis()
//    while(count < iterations) do
//      let new_match_m = short_lst.map[U64](lambda(x: U64): U64 => x * 2 end)
//      count = count + 1
//    end
//    perf_end = Time.millis()
//    Time.perf_end()
//    Debug.out("Match map (SHORT): " + (perf_end - perf_begin).string())
//
//    count = 0
//    Time.perf_begin()
//    perf_begin = Time.millis()
//    while(count < iterations) do
//      let new_match_m = short_lst.map_try[U64](lambda(x: U64): U64 => x * 2 end)
//      count = count + 1
//    end
//    perf_end = Time.millis()
//    Time.perf_end()
//    Debug.out("Try map (SHORT): " + (perf_end - perf_begin).string())

//  fun list_bench(iterations: U64, keys: U64) =>
//    var list: List[U64] = Lists.empty[U64]()
//    // Different seed each run
//    let dice = Dice(MT)
//    var count: U64 = 0
//    var perf_begin: U64 = 0
//    var perf_end: U64 = 0
//
//    var l1: List[U64] = Lists.empty[U64]()
//    var l2: List[U64] = Lists.empty[U64]()
//    var l3: List[U64] = Lists.empty[U64]()
//    var l4: List[U64] = Lists.empty[U64]()
//
//    while(count < iterations) do
//      let v: U64 = dice(1,100000)
//      l1 = l1.prepend(v)
//      l2 = l2.prepend(v)
//      l3 = l3.prepend(v)
//      l4 = l4.prepend(v)
//      count = count + 1
//    end
//
//    //WRITES
//    Time.perf_begin()
//    perf_begin = Time.millis()
////    l1.reverse()
////    l2.reverse()
////    l3.reverse()
////    l4.reverse()
////    l1.reverse()
////    l2.reverse()
////    l3.reverse()
////    l4.reverse()
////    l1.reverse()
////    l2.reverse()
////    l3.reverse()
////    l4.reverse()
//    perf_end = Time.millis()
//    Time.perf_end()
//    Debug.out("TRY: reverse: " + (perf_end - perf_begin).string())

//    Time.perf_begin()
//    perf_begin = Time.millis()
////    l1.concat(l2)
////    l2.concat(l3)
////    l3.concat(l4)
////    l4.concat(l1)
////    l1.concat(l2)
////    l2.concat(l3)
////    l3.concat(l4)
////    l4.concat(l1)
////    l1.concat(l2)
////    l2.concat(l3)
////    l3.concat(l4)
////    l4.concat(l1)
//    perf_end = Time.millis()
//    Time.perf_end()
//    Debug.out("TRY: concat: " + (perf_end - perf_begin).string())
