use std::io;

fn square(x : i32) -> i32 {
    return x * x;
}

fn sumSquareDigits(n : i32) -> i32 {
    let mut s = 0;
    let mut x = n;
    while x > 0 {
        s = s + square(x % 10);
        x /= 10;
    }
    return s;
}

static N : u32 = 10000000;

fn main() {
    fn termination(x:usize) -> usize {
        let mut t = x;
        while !(t == 1 || t == 89) {
            t = sumSquareDigits(t as i32) as usize;
        }
        return t;
    }
    
    fn countT89(n:u32) -> u32 {
        let mut count = 0;
        let mut i = 1;
        while i < n {
            if termination(i as usize) == 89 {
                count += 1;
            }
            i += 1;
        }
        return count;
    }
    
    println!("Calculating # of sumsquaredigits terminating in 89 from 1 to 10,000,000...");
    println!("{}", countT89(N));
    println!("Press Enter to continue");
    let mut guess = String::new();
    io::stdin()
        .read_line(&mut guess)
        .expect("Failed to read line");
}