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

# This cache is not helpful:

# ssdCache = Array{Int16}(undef,1000)
# for i in 0:999
#     ssdCache[i+1] = sumSquareDigits(i)
# end

# function ssd2(n)
#     return  ssdCache[div(n,1_000_000)%1000+1] + 
#             ssdCache[div(n,1_000)%1000+1] + 
#             ssdCache[n%1000+1] 
# end

function terminator(n) 
    if n > 1 && n != 89 
        return terminator(sumSquareDigits(n))
        # surprisingly, this does not improve the timing! :
        # return terminator(ssd2(n)) 
        # Julia is optizing div by a constant as multiplication by the inverse!
        # good job, compiler writers!!
    else
        return n > 1
    end 
end

function makecache()
    global cache = BitArray([ terminator(i) for i in 1:cachelen+1 ])
end

makecache()

function answer(n::Int64)
    return sum(cache[sumSquareDigits(i)] for i=1:n)
end

print("Answer to PE92 = ",answer(N))
@time(answer(N)) # About 0.6 seconds on macbook pro 2015 i7 
# @code_native(sumSquareDigits(1)) 
# multiplication by inverse used:
#        movabsq $7378697629483820647, %r8 # 2^66/10 ...