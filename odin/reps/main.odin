package main

import reps "tester"
import "base:intrinsics"
import "core:fmt"

asm_test :: struct {
	name:  string,
	func:  cache_func,
	count: uint,
}

cache_test :: struct {
	name: string,
	func: cache_func,
	mask: uint,
}

repetition_test :: struct {
	name:        string,
	func:        test_func,
	with_malloc: bool,
}

gb := 1024 * 1024 * 1024
size := 4 * gb


// tests :: [?]repetition_test {
// 	{"cache_4k", cache_4k, false},
// 	{"cache_64k", cache_64k, false},
// 	{"cache_1m", cache_1m, false},
// 	{"cache_16m", cache_16m, false},
// 	{"cache_256m", cache_256m, false},
// 	{"cache_4g", cache_4g, false},
// }
path :: "../data/pairs.json"

main :: proc() {
	tests := [?]repetition_test{{"read_16x3", read_16x3, false}, {"read_32x3", read_32x3, false}}

	testers: [len(tests)]reps.tester
	cpu_freq := intrinsics.read_cycle_counter_frequency()

	dest := make([]byte, size)
	for i in 0 ..< size {
		dest[i] = byte(i)
	}

	for {
		for test, i in tests {
			fmt.printf("\n--- %s", test.name)
			fmt.print(" ---\n")
			t := testers[i]
			reps.start_wave(&t, cpu_freq)
			test.func(&t, path, test.with_malloc)
		}
	}
}

nop_test :: proc() {
	testers: [branch_pattern]reps.tester
	cpu_freq := intrinsics.read_cycle_counter_frequency()

	for {
		for pattern in branch_pattern {
			buffer := make([]byte, 1024 * 1024 * 1024)
			fill_buffer(buffer, pattern)
			fmt.printf("\n--- conditional_nop, %s ---\n", pattern)
			fmt.println(buffer[:32])
			fmt.println(buffer[len(buffer) - 32:])

			t := testers[pattern]
			reps.start_wave(&t, cpu_freq)
			conditional_nop(&t, buffer)

			delete(buffer)
		}
	}
}
