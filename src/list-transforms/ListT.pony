use "collections"
use "../function-types"

primitive ListT
  fun unit[A](a: A): List[A] => List[A].push(consume a)

  fun map[A: Any #read, B](l: List[A], f: Fn1[A!, B^]): List[B] =>
    try
      _map[A, B](l.head(), f, List[B])
    else
      List[B]
    end

  fun _map[A: Any #read, B](ln: ListNode[A], f: Fn1[A!, B^], acc: List[B]): List[B] =>
    try acc.push(f(ln())) end

    try
      _map[A, B](ln.next() as ListNode[A], f, acc)
    else
      acc
    end

  fun flatMap[A: Any #read, B](l: List[A], f: Fn1[A!,List[B]]): List[B] =>
    try
      _flatMap[A,B](l.head(), f, List[List[B]])
    else
      List[B]
    end

  fun _flatMap[A: Any #read, B](ln: ListNode[A], f: Fn1[A!,List[B]], acc: List[List[B]]): List[B] =>
    try acc.push(f(ln())) end

    try
      _flatMap[A,B](ln.next() as ListNode[A], f, acc)
    else
      flatten[B](acc)
    end

  fun flatten[A](l: List[List[A]]): List[A] =>
    let resList = List[A]
    for subList in l.values() do
      resList.append_list(subList)
    end
    resList

  fun filter[A: Any #read](l: List[A], f: Fn1[A!, Bool]): List[A] =>
    try
      _filter[A](l.head(), f, List[A])
    else
      List[A]
    end

  fun _filter[A: Any #read](ln: ListNode[A], f: Fn1[A!, Bool], acc: List[A]): List[A] =>
    try
      let cur = ln()
      if (f(cur)) then acc.push(consume cur) end
    end

    try
      _filter[A](ln.next() as ListNode[A], f, acc)
    else
      acc
    end

  fun fold[A: Any #read,B: Any #read](l: List[A], f: Fn2[B!,A!,B^], acc: B): B =>
    try
      _fold[A,B](l.head(), f, acc)
    else
      acc
    end

  fun _fold[A: Any #read,B: Any #read](ln: ListNode[A], f: Fn2[B!,A!,B^], acc: B!): B =>
    let nextAcc: B! = try f(acc, ln()) else acc end

    try
      _fold[A,B](ln.next() as ListNode[A], f, nextAcc)
    else
      nextAcc
    end

  fun every[A: Any #read](l: List[A], f: Fn1[A!,Bool]): Bool =>
    try
      return _every[A](l.head(), f)
    else
      return true
    end

  fun _every[A: Any #read](ln: ListNode[A], f: Fn1[A!,Bool]): Bool =>
    try
      let a: A = ln()
      if (not(f(a))) then
        return false
      elseif (not(ln.has_next())) then
        return true
      else
        return _every[A](ln.next() as ListNode[A], f)
      end
    else
      return true
    end

  fun exists[A: Any #read](l: List[A], f: Fn1[A!,Bool]): Bool =>
    try
      return _exists[A](l.head(), f)
    else
      return false
    end

  fun _exists[A: Any #read](ln: ListNode[A], f: Fn1[A!,Bool]): Bool =>
    try
      let a: A = ln()
      if (f(a)) then
        return true
      elseif (not(ln.has_next())) then
        return false
      else
        return _exists[A](ln.next() as ListNode[A], f)
      end
    else
      return false
    end

  fun partition[A: Any #read](l: List[A], f: Fn1[A!,Bool]): (List[A], List[A]) =>
    let l1: List[A] = List[A]
    let l2: List[A] = List[A]
    for item in l.values() do
      if (f(item)) then l1.push(item) else l2.push(item) end
    end
    (l1, l2)

  fun drop[A](l: List[A], n: U64): List[A] =>
    if (l.size() < n) then return List[A] end

    try
      let res = _drop[A](l.head(), n)
      List[A].append_node(res)
    else
      List[A]
    end

  fun _drop[A](ln: ListNode[A], n: U64): ListNode[A] =>
    var count = n
    var cur: ListNode[A] = ln
    while(count > 0) do
      try cur = cur.next() as ListNode[A] end
    end
    cur

//    try
//      _partition[A](l.head(), f)
//    else
//      (List[A], List[A])
//    end
//
//  fun _partition[A](ln: ListNode[A], f: Fn1[A!,Bool]): (List[A], List[A]) =>
//    let l1: List[A] = List[A]
//    let l2: List[A] = List[A]


//  fun fold[A: Any #read,B: Any #read](acc: B): Fn2[List[A],Fn2[B!,A!,B^],B] =>
//    object
//      let b: B = acc
//
//      fun apply(l: List[A], f: Fn2[B!,A!,B^]): this->B =>
//        try
//          _fold(l.head(), f, b)
//        else
//          b
//        end
//
//      fun _fold(ln: ListNode[A], f: Fn2[B!,A!,B^], acc: this->B!): B =>
//        let nextAcc: B! = try f(acc, ln()) else acc end
//
//        try
//          _fold[A,B](ln.next() as ListNode[A], f, nextAcc)
//        else
//          nextAcc
//        end
//    end



