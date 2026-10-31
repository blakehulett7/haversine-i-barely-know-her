package metrics

import "core:fmt"

print_time_elapsed :: proc(label: string, total_elapsed, prof_begin, prof_end: u64) {
	elapsed := prof_end - prof_begin
	percent := 100.0 * (f64(elapsed) / f64(total_elapsed))
	fmt.printf("  %s: %d (%.2f%%)\n", label, elapsed, percent)
}
