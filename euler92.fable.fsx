// Learn more about F# at http://fsharp.net
// See the 'F# Tutorial' project for more help.
// 4.5 seconds with no memoization
// 6.5 seconds with map memoization
// 2.0 seconds with int[] size 10000
 
open System
open System.Collections.Generic

let square (x:int) : int = x*x 
let sumSquareDigits (n:int) : int=
     let mutable s = 0
     let mutable x = n
     while x > 0 do
         s <- s + square(x % 10)
         x <- x / 10
     s

let ssdCache:int[] = Array.zeroCreate 10000

for i = 1 to 9999 do
    ssdCache.[i] <- sumSquareDigits i

let ssd2 (x:int) : int = ssdCache.[x % 10000] + if x > 9999 then ssdCache.[x / 10000] else 0

let rec termination x = if x = 1 || x = 89 then x
                         else termination (ssd2 x)

// 4.5 seconds
let countT89 () =
     let mutable count = 0 in
     for i = 1 to 10000000 do
         if (termination i) = 89 then
             count <- count + 1
         else ()
     count

let createDic (key:'a) (value:'b) = Dictionary<'a, 'b> () 
let collateArg (arg: 'TArg) (f : 'TArg -> 'TResult) = fun a -> f a

//http://fssnip.net/1q
//[<CompiledName("Memoize")>]
let memoize1 f =
   let dic = createDic Unchecked.defaultof<'TArg1> Unchecked.defaultof<'TResult>
   fun x -> match dic.TryGetValue(x) with
            | true, r -> r
            | _       -> dic.[x] <- f x
                         dic.[x]

let termmemo = memoize1 termination

//// 6.44 seconds (longer)
//let countT89memo () =
//     let mutable count = 0 in
//     for i = 1 to 10000000 do
//         if (termination i) = 89 then
//             count <- count + 1
//         else ()
//     count

let startTime = DateTime.Now
printfn "Calculating # of sumsquaredigits terminating in 89 from 1 to 10,000,000..."
printfn "%d"  <| countT89 () // 4.5 seconds 
let endTime = DateTime.Now 
let elapsed = endTime - startTime 
printfn "elapsed=%A (%A-%A)"  elapsed startTime  endTime  
