package main

import "base:intrinsics"
import "core:fmt"

repetition_test :: struct {
	name:        string,
	func:        test_func,
	with_malloc: bool,
}

tests :: [?]repetition_test {
	{"nop_x9", nop_x9, false},
	{"nop_x18", nop_x18, false},
	{"nop_4x1", nop_4x1, false},
	{"nop_4x3", nop_4x3, false},
	{"nop_4x9", nop_4x9, false},
	{"nop_x1", nop_x1, false},
	{"nop_x3", nop_x3, false},
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
