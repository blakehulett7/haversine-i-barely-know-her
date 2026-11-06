package main

import "base:intrinsics"
import "core:fmt"

test_func :: struct {
	name: string,
	func: read_func,
}

tests :: [?]test_func {
	{"write_all", write_all_bytes},
	{"read_entire_file", default},
	{"read + malloc", with_malloc},
}
path :: "../data/pairs.json"

main :: proc() {
	testers: [len(tests)]tester
	cpu_freq := intrinsics.read_cycle_counter_frequency()

	for {
		for test, i in tests {
			fmt.printf("\n--- %s ---\n", test.name)
			t := testers[i]
			start_wave(&t, cpu_freq)
			test.func(&t, path)
		}
	}
}
