use "../"
use mut = "collections"
use "time"
use "debug"
use "random"


primitive Bench
  fun bench(iterations: U64, keys: U64) ? =>
    var pMap: Map[String,U64] = Maps.empty[String,U64]()
    let mMap: mut.Map[String,U64] = mut.Map[String,U64]()
    let kvs = Array[(String,U64)]()
    // Different seed each run
    let dice = Dice(MT(Time.millis()))
    var count: U64 = 0
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
      pMap = pMap.put(k, v)
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
      let pmv = pMap.get(kvs(count)._1)
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
