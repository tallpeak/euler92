const std = @import("std");


const LIMIT : u32 = 10000000;

var sqdigit : [10]u32 = .{0,1,4,9,16,25,36,49,64,81};

fn ssd(x : u32) u32
{
    var s : u32 = 0;
    var t : u32 = x;
    while (t>0) {
        s += sqdigit[t % 10];
        t /= 10;
    }
    return s;
}

fn termination(x : u32) u32
{
    var t = x;
    while (t != 1 and t != 89)
    {
        t = ssd(t);
    }
    return t;
}

fn countT89() u32
{
    var count : u32 = 0;
    var i : u32 = 1;
    while (i < LIMIT)
    {
        //printf("%d=%d %d\t",i,termination(i),count);
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


