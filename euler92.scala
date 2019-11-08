import java.util.Date
// 1.6 seconds with no memoization
// 7.0 seconds generic-memoized (removed this code)
// 0.9 seconds with Array[Int] size 10000
// 1.1 seconds with Array[Int] size 1000
// 0.75 seconds with Array[Int] size 1000 but ifs to only read the array when needed

object euler92 {		

     def digits(n: Int): List[Int] = {
         var x = n
         var l = List[Int]()
         while (x > 0) {
             l = (x%10) :: l
             x = x / 10
         }
         l
     }

     def sumSquareDigits(n: Int): Int = {
         var x = n
         var acc = 0
         while (x > 0) {
             val d = (x%10)
             acc = acc + (d*d)
             x = x / 10
         }
         acc
     }

     val cacheSize = 1000
 
     val ssdCache: Array[Int] = (0 to cacheSize-1).map(i => sumSquareDigits(i)).toArray

     //equivalent, more imperitive approach to the above line:
     //var ssdCache: Array[Int] = Array(0, cacheSize)
     //Array.fill(cacheSize)(0)
     //for (i <- 0 to (cacheSize-1))
     //{
     	//ssdCache(i) = sumSquareDigits(i)
     //}
     
     // unrolled loop, sufficient for up to 1 billion elements
     def ssd2(n: Int) : Int =	ssdCache(n % 1000) +
     				(if (n > 999) 	ssdCache(n / 1000 % 1000) 	 else 0) +
	     			(if (n > 999999)ssdCache(n / 1000000 % 1000) else 0)
     
     def sumSquareDigits_memo = memo(sumSquareDigits)

     def terminator(x: Int): Int = {
         if (x == 89 || x == 1) x
         else terminator(ssd2(x)) // sumSquareDigits
     }
     
     def count89(n:Int) : (Int, Double) = {
         val t0 = System.nanoTime()
         var c = 0
         for (i <- 1 to n)
         {
             if (terminator(i) == 89)
                 c += 1
         }
         val t1 = System.nanoTime()
         val elapsed = t1 - t0
         (c, elapsed / 1e9)
     };
	
     val tenmil = 10000000
     count89(tenmil)    
}
