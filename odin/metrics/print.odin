package metrics

import "core:fmt"

print_time_elapsed :: proc(label: string, total_elapsed: i64, anchor: anchor) {
	anchor_elapsed := anchor.elapsed - anchor.elapsed_children
	percent := 100.0 * (f64(anchor_elapsed) / f64(total_elapsed))
	fmt.printf("  %s[%d]: %d (%.2f%%", label, anchor.hits, anchor_elapsed, percent)
	if anchor.elapsed_children != 0 {
		percent_with_children := 100.0 * (f64(anchor.elapsed) / f64(total_elapsed))
		fmt.printf(", %.2f%% w/children", percent_with_children)
	}
	fmt.printf(")\n")
}
