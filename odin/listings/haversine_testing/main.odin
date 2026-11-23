package main

import "../../bath"
import "../../calc"
import "../../generator"
import reps "../../reps/tester"
import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:slice"

main :: proc() {
	tests := [?]repetition_test{{"Reference", calc.reference_haversine}, {"Bath", bath.haversine}}

	testers: [len(tests)]reps.tester
	cpu_freq := intrinsics.read_cycle_counter_frequency()

	data, err := os.read_entire_file("../../data/pairs.f64", context.allocator)
	if err != nil {
		fmt.println("could not read input pairs")
		os.exit(1)
	}

	pairs := slice.reinterpret([]generator.Pair, data)
	size := f64(len(pairs))
	target_size := u64(size * size_of(generator.Pair))

	for {
		for test, i in tests {
			fmt.printf("\n--- %s", test.name)
			fmt.print(" ---\n")
			t := testers[i]
			reps.start_wave(&t, cpu_freq)

			for reps.is_testing(&t) {
				reps.begin_time(&t)
				haversine_sum: f64
				for pair in pairs {
					sum := test.func(pair.x0, pair.y0, pair.x1, pair.y1)
					haversine_sum += sum
				}
				avg := haversine_sum / size
				reps.end_time(&t, target_size)
			}
		}
	}
}
