interface box Fn0[OUT]
    fun apply(): OUT ?
interface box Fn1[IN1: Any #read,OUT]
    fun apply(a: IN1): OUT ?
interface box Fn2[IN1: Any #read,IN2: Any #read,OUT]
    fun apply(a: IN1, b: IN2): OUT ?
interface box Fn3[IN1: Any #read,IN2: Any #read,IN3: Any #read,OUT]
    fun apply(a: IN1, b: IN2, c: IN3): OUT ?
interface box Fn4[IN1: Any #read,IN2: Any #read,IN3: Any #read,IN4: Any #read,OUT]
    fun apply(a: IN1, b: IN2, c: IN3, d: IN4): OUT ?
interface box Fn5[IN1: Any #read,IN2: Any #read,IN3: Any #read,IN4: Any #read,IN5: Any #read,OUT]
    fun apply(a: IN1, b: IN2, c: IN3, d: IN4, e: IN5): OUT ?
interface box SeFn1[IN1: Any #read]
    fun apply(a: IN1) ?