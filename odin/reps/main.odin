package main

import "base:intrinsics"
import "core:fmt"

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
	tests := [32 - 12]cache_test{}

	testers: [len(tests)]tester
	cpu_freq := intrinsics.read_cycle_counter_frequency()

	dest := make([]byte, size)
	for i in 0 ..< size {
		dest[i] = byte(i)
	}

	for &test, i in tests {
		test.mask = uint(i) + 12
		test.name = fmt.tprintf("Cache %d", 1 << test.mask)
		test.func = custom_cache
	}

	for {
		for test, i in tests {
			fmt.printf("\n--- %s", test.name)
			fmt.print(" ---\n")
			t := testers[i]
			start_wave(&t, cpu_freq)
			test.func(&t, dest, test.mask)
		}
	}
}

nop_test :: proc() {
	testers: [branch_pattern]tester
	cpu_freq := intrinsics.read_cycle_counter_frequency()

	for {
		for pattern in branch_pattern {
			buffer := make([]byte, 1024 * 1024 * 1024)
			fill_buffer(buffer, pattern)
			fmt.printf("\n--- conditional_nop, %s ---\n", pattern)
			fmt.println(buffer[:32])
			fmt.println(buffer[len(buffer) - 32:])

			t := testers[pattern]
			start_wave(&t, cpu_freq)
			conditional_nop(&t, buffer)

			delete(buffer)
		}
	}
}
