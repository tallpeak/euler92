//translated from python

//from Euler import sos_digits # as suggested by Po
let L = 10000000
let Lc = 9*9 * 7

let square (x:int) : int = x*x 
let sumSquareDigits (n:int) : int=
     let mutable s = 0
     let mutable x = n
     while x > 0 do
         s <- s + square(x % 10)
         x <- x / 10
     s

let rec nc n = if n > 1 && n <> 89 && n <> 4 
               then nc (sumSquareDigits n)
               else n > 1

let cache = [| for i = 0 to (Lc+1) do yield nc i |]

let pe92 = Seq.sumBy(fun b -> if b then 1 else 0) 
                ( seq { for i = 1 to L do yield cache.[sumSquareDigits i] } )

printfn "Answer to PE92 = %d" pe92

