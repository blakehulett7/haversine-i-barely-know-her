package metrics

import "core:fmt"

print_time_elapsed :: proc(label: string, total_elapsed: i64, anchor: anchor) {
	percent := 100.0 * (f64(anchor.elapsed_exclusive) / f64(total_elapsed))
	fmt.printf("  %s[%d]: %d (%.2f%%", label, anchor.hits, anchor.elapsed_exclusive, percent)
	if anchor.elapsed_exclusive != anchor.elapsed_inclusive {
		percent_with_children := 100.0 * (f64(anchor.elapsed_inclusive) / f64(total_elapsed))
		fmt.printf(", %.2f%% w/children", percent_with_children)
	}
	fmt.printf(")\n")
}
