// euler92.go; my first go program
// without memoization
// var ssdCache = map[int]int{}
package main
import "fmt"
var LIMIT = 10000000
var sqdigit = []int{0,1,4,9,16,25,36,49,64,81}

func ssd(x int) int {
	s := 0
	t := x
	for t > 0 {
		s += sqdigit[t % 10]
		t /= 10
	}
	return s
}

func termination(x int) int {
	t := x
	for t != 1 && t != 89 {
		t = ssd(t)
	}
	return t
}

func countT89() int {
	count := 0
	var i int
	for i = 1; i < LIMIT; i++{
		if termination(i) == 89 {
			count++
		}
	}
	return count
}

func main() {
	var cnt = countT89()
	fmt.Println("count terminating at 89=", cnt)
}