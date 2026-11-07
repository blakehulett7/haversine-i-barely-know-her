package main

import "base:intrinsics"
import "core:fmt"

repetition_test :: struct {
	name:        string,
	func:        test_func,
	with_malloc: bool,
}

tests :: [?]repetition_test {
	{"write_all", write_all_bytes, false},
	{"write_all", write_all_bytes, true},
	{"read_entire_file", default, false},
	{"read_entire_file", default, true},
}
path :: "../data/pairs.json"

main :: proc() {
	testers: [len(tests)]tester
	cpu_freq := intrinsics.read_cycle_counter_frequency()

	for {
		for test, i in tests {
			fmt.printf("\n--- %s", test.name)
			if test.with_malloc {
				fmt.print(" + malloc")
			}
			fmt.print(" ---\n")
			t := testers[i]
			start_wave(&t, cpu_freq)
			test.func(&t, path, test.with_malloc)
		}
	}
}
