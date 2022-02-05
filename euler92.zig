const std = @import("std");
const LIMIT : u32 = 10000000;
//var sqdigit : [10]u32 = .{0,1,4,9,16,25,36,49,64,81};
fn sq(x:u32) u32 {
    return x*x;
}

fn ssd(x : u32) u32 // sum of squares of digits
{
    var s : u32 = 0;
    var t : u32 = x;
    while (t>0) {
        s += sq(t%10); //sqdigit[t % 10];
        t /= 10;
    }
    return s;
}

// use compile-time code to initialize an array
var ssdCache = init : {
    var initial_value: [1000]u16 = undefined;
    @setEvalBranchQuota(10001);
    for (initial_value) |*p, i| {
        p.* = ssd(i);
    }
    break :init initial_value;
};

fn ssd2(x : u32) u32 {
    return ssdCache[x % 1000] + 
        (if (x > 999) ssdCache[ x / 1000 % 1000] else 0) + 
        (if (x > 999999) ssdCache[ x / 1000000 % 1000] else 0) ;
}

fn termination(x : u32) u32
{
    var t = x;
    while (t != 1 and t != 89)
    {
        t = ssd2(t);
    }
    return t;
}

fn countT89() u32
{
    var count : u32 = 0;
    var i : u32 = 1;
    while (i < LIMIT)
    {
        if (termination(i) == 89)
            count += 1;
        i += 1;
    }
    return count;
}

pub fn main() void {
    var cnt = countT89();
    std.debug.print("count terminating at 89={}\n",.{cnt});
}


