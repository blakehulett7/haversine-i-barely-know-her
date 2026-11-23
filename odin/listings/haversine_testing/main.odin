package main

import "../../bath"
import "../../calc"
import "../../generator"
import reps "../../reps/tester"
import "base:intrinsics"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"

Expected_AVG :: 1684.9479155032038

main :: proc() {
	tests := [?]repetition_test {
		{"Reference", ref_pairs},
		{"Bath", bath_pairs},
		{"Expanded", bath.expanded_haversine},
		{"v1", bath.simplified_haversine_v1},
		{"v2", bath.simplified_haversine_v2},
		{"v3", bath.simplified_haversine_v3},
		{"v4", bath.simplified_haversine_v4},
		{"v5", bath.simplified_haversine_v5},
		{"v6", bath.simplified_haversine_v6},
	}

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

	max_err: f64

	for {
		for test, i in tests {
			fmt.printf("\n--- %s", test.name)
			fmt.print(" ---\n")
			t := testers[i]
			reps.start_wave(&t, cpu_freq)

			for reps.is_testing(&t) {
				reps.begin_time(&t)
				avg := test.func(pairs)
				reps.end_time(&t, target_size)

				if avg != Expected_AVG {
					max_err = math.abs(max(max_err, avg - Expected_AVG))
				}
			}

			if max_err != 0 {
				fmt.printfln("max_err: %.17f", max_err)
				max_err = 0
			}
		}
	}
}

ref_pairs :: proc(pairs: []generator.Pair) -> f64 {
	sum: f64
	for pair in pairs {
		sum += calc.reference_haversine(pair.x0, pair.y0, pair.x1, pair.y1)
	}
	return sum / f64(len(pairs))
}

bath_pairs :: proc(pairs: []generator.Pair) -> f64 {
	sum: f64
	for pair in pairs {
		sum += bath.haversine(pair.x0, pair.y0, pair.x1, pair.y1)
	}
	return sum / f64(len(pairs))
}
