open System
open System.Diagnostics 
let t0 = new Stopwatch()
t0.Start()
let max = 10000000
// define function to add the square of the digits in a number
let inline square (x:int) : int = x*x 
let addSquaredDigits (n:int) : int =
    let rec go s x = if x = 0 then s else go (s + square(x % 10)) (x / 10) in go 0 n
// build up a cache for just the first 568 or so numbers
let cache = Array.init (addSquaredDigits (max-1) + 1) (fun n -> match n with | 0 | 1 -> Some(false) | 89 -> Some(true) | _ -> None)
let processChain n =
    let rec processChainRec n (list: int list) : bool option=
        if cache.[n] = None then processChainRec (addSquaredDigits n) (list@[n])
    else 
        list |> List.iter (fun n' -> cache.[n'] <- cache.[n])
        cache.[n]
    processChainRec (addSquaredDigits n) []

// go through all the numbers from 2 to 10 million using the above function
let mutable answer = 0
for i = 2 to max do
    answer <- answer + (processChain i) with | Some(true) -> 1 | _ -> 0
printfn "Answer=%d, %d ms" answer t0.ElapsedMilliseconds
