// translated from euler92.go; go and swift seems somewhat similar
var LIMIT = 10000000
var sqdigit = [0,1,4,9,16,25,36,49,64,81]

func ssd(x: Int) -> Int {
    var s = 0
    var t = x
    while t > 0 {
        s += sqdigit[t % 10]
        t /= 10
    }
    return s
}

func termination(x: Int) -> Int {
    var t = x
    while t != 1 && t != 89 {
        t = ssd(x: t)
    }
    return t
}

func countT89() -> Int {
    var count = 0
    for i in 1 ..< LIMIT {
        if termination(x: i) == 89 {
            count+=1
        }
    }
    return count
}

let cnt = countT89()
print("count terminating at 89=\(cnt)")