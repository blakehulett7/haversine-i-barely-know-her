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
	{"mov_all_bytes", mov_all_bytes, false},
	{"nop_all_bytes", nop_all_bytes, false},
	{"cmp_all_bytes", cmp_all_bytes, false},
	{"dec_all_bytes", dec_all_bytes, false},
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
