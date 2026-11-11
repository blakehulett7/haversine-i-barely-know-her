package main

import "base:intrinsics"
import "core:fmt"

repetition_test :: struct {
	name:        string,
	func:        test_func,
	with_malloc: bool,
}

gb := 1024 * 1024 * 1024

tests :: [?]repetition_test {
	{"read_x1", read_x1, false},
	{"read_x2", read_x2, false},
	{"read_x3", read_x3, false},
	{"read_x4", read_x4, false},
	{"write_x1", write_x1, false},
	{"write_x2", write_x2, false},
	{"write_x3", write_x3, false},
	{"write_x4", write_x4, false},
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
