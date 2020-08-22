# translated from F#
N = 10_000_000
cachelen = Int(9*9 * ceil(log(N)/log(10)))
square(x) = x*x

function sumSquareDigits(n) 
    s = Int(0)
    x = Int(n)
    while(x > 0)
         s += square(x % 10)
         x = div(x,10) # x ÷= 10
    end
    return s
end

function nc(n) 
    if n > 1 && n != 89 && n != 4 
        return nc(sumSquareDigits(n))
    else
        return n > 1
    end 
end
function makecache()
    global cache = BitArray([ nc(i) for i in 1:cachelen+1 ])
end
makecache()
function answer(n::Int64)
    local pe92 = Int64(0)
    for i in 1:n
        pe92 += cache[sumSquareDigits(i)]
    end
    return pe92
end

print("Answer to PE92 = ",answer(N))
@time(answer(N)) # 0.6 seconds on macbook pro 2015 i7 