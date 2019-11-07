import java.util.Date
// 1.6 seconds with no memoization
// 7.0 seconds generic-memoized
// 0.9 seconds with Array[Int] size 10000
// 1.1 seconds with Array[Int] size 1000
// 0.75 seconds with Array[Int] size 1000 but ifs to only read the array when needed

object euler92 {
	
		case class memo(f: Int => Int) {
		  // We aren't going to synchronize cache access, because
		  // it's harmless if two threads right the same key-value
		  // to the cache simultaneously!
		  val cache = scala.collection.mutable.Map.empty[Int,Int]
		  def apply(i: Int): Int = cache.get(i) match {
		    case Some(l) => l
		    case None =>
		      val l = f(i)
		      cache.put(i,l)
		      l
		  }
		}
		
			// Implementation without using pattern matching.
		case class memo2(f: Int => Int) {
		  val cache = scala.collection.mutable.Map.empty[Int,Int]
		  def apply(i: Int): Int = {
		    val optionl = cache.get(i)
		    if (optionl == None) {
		      val l = f(i)
		      cache.put(i,l)
		      l
		    } else {
		      optionl.get
		    }
		  }
		};
		//import org.scalaide.worksheet.runtime.library.WorksheetSupport._;
		
		//def main(args: Array[String])
			

     def digits(n: Int): List[Int] = {
         var x = n
         var l = List[Int]()
         while (x > 0) {
             l = (x%10) :: l
             x = x / 10
         }
         l
     }                                            //> digits: (n: Int)List[Int]

     def sumSquareDigits(n: Int): Int = {
         var x = n
         var acc = 0
         while (x > 0) {
             val d = (x%10)
             acc = acc + (d*d)
             x = x / 10
         }
         acc
     }                                            //> sumSquareDigits: (n: Int)Int

     val cacheSize = 1000                         //> cacheSize  : Int = 1000
 
     val ssdCache: Array[Int] = (0 to cacheSize-1).map(i => sumSquareDigits(i)).toArray
                                                  //> ssdCache  : Array[Int] = Array(0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 1, 2, 5,
                                                  //|  10, 17, 26, 37, 50, 65, 82, 4, 5, 8, 13, 20, 29, 40, 53, 68, 85, 9, 10, 13
                                                  //| , 18, 25, 34, 45, 58, 73, 90, 16, 17, 20, 25, 32, 41, 52, 65, 80, 97, 25, 2
                                                  //| 6, 29, 34, 41, 50, 61, 74, 89, 106, 36, 37, 40, 45, 52, 61, 72, 85, 100, 11
                                                  //| 7, 49, 50, 53, 58, 65, 74, 85, 98, 113, 130, 64, 65, 68, 73, 80, 89, 100, 1
                                                  //| 13, 128, 145, 81, 82, 85, 90, 97, 106, 117, 130, 145, 162, 1, 2, 5, 10, 17,
                                                  //|  26, 37, 50, 65, 82, 2, 3, 6, 11, 18, 27, 38, 51, 66, 83, 5, 6, 9, 14, 21, 
                                                  //| 30, 41, 54, 69, 86, 10, 11, 14, 19, 26, 35, 46, 59, 74, 91, 17, 18, 21, 26,
                                                  //|  33, 42, 53, 66, 81, 98, 26, 27, 30, 35, 42, 51, 62, 75, 90, 107, 37, 38, 4
                                                  //| 1, 46, 53, 62, 73, 86, 101, 118, 50, 51, 54, 59, 66, 75, 86, 99, 114, 131, 
                                                  //| 65, 66, 69, 74, 81, 90, 101, 114, 129, 146, 82, 83, 86, 91, 98, 107, 118, 1
                                                  //| 31, 146, 163, 4, 5, 8, 13, 20, 29, 40, 53, 68, 85, 5, 6, 9, 14, 21, 30, 41,
                                                  //|  54, 69, 86, 8, 9, 12, 
                                                  //| Output exceeds cutoff limit.

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
                                                  //> ssd2: (n: Int)Int

		 def sumSquareDigits_memo = memo(sumSquareDigits)
                                                  //> sumSquareDigits_memo: => euler92.memo

     def terminator(x: Int): Int = {
         if (x == 89 || x == 1) x
         else terminator(ssd2(x)) // sumSquareDigits
     }                                            //> terminator: (x: Int)Int
     
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
     };//System.out.println("""count89: (n: Int)(Int, Double)""");$skip(28);
                                                  //> count89: (n: Int)(Int, Double)

     val tenmil = 10000000                        //> tenmil  : Int = 10000000
     count89(tenmil)                              //> res0: (Int, Double) = (8581146,0.5133675)
     
}



//class Memoize1[-T, +R](f: T => R) extends (T => R) {
//  import scala.collection.mutable
//  private[this] val vals = mutable.Map.empty[T, R]
//
//  def apply(x: T): R = {
    //if (vals.contains(x)) {
//      vals(x)
    //}
    //else {
    //  val y = f(x)
//      vals += ((x, y))
      //y
//    }
//  }
//}
 
//object Memoize1 {
//  def apply[T, R](f: T => R) = new Memoize1(f)
//}
