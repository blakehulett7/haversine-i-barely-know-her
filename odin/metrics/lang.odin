package metrics

import "core:fmt"
import "core:time"

language_time_test :: proc() {
	start := time.now()

	// TODO: Work

	elapsed := time.since(start)
	fmt.printf("Elapsed time: %f ns\n", time.duration_nanoseconds(elapsed))
}
