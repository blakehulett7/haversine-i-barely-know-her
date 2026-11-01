package metrics

import "core:fmt"

print_time_elapsed :: proc(label: string, total_elapsed, anchor_elapsed, anchor_hits: i64) {
	percent := 100.0 * (f64(anchor_elapsed) / f64(total_elapsed))
	fmt.printf("  %s: %d (%.2f%%) - %d Hits\n", label, anchor_elapsed, percent, anchor_hits)
}
