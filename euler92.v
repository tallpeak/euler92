// see vlang.io or github.com/vlang
const limit = 10000000
const sqdigit = [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

fn ssd(x int) int {
	mut s := 0
	mut t := x
	for t > 0 {
		s += sqdigit[t%10]
		t /= 10
	}
	return s
}

fn termination(x int) int {
	mut t := x
	for t != 1 && t != 89 {
		t = ssd(t)
	}
	return t
}

fn count_t89() int {
	mut count := 0
	for i := 1; i < limit; i++ {
		if termination(i) == 89 {
			count++
		}
	}
	return count
}

fn main() {
	cnt := count_t89()
	println("count terminating at 89=$cnt")
}
