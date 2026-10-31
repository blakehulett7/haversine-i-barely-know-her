package metrics

import "core:fmt"
import "core:time"

language_time_test :: proc() {
	start := time.now()

	elapsed := time.since(start)
	fmt.printf("Elapsed time: %d ns\n", time.duration_nanoseconds(elapsed))
}
