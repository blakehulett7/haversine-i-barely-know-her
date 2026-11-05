package metrics

import "core:fmt"

print_time_elapsed :: proc(label: string, total_elapsed, freq: i64, anchor: anchor) {
	percent := 100.0 * (f64(anchor.elapsed_exclusive) / f64(total_elapsed))
	fmt.printf("  %s[%d]: %d (%.2f%%", label, anchor.hits, anchor.elapsed_exclusive, percent)
	if anchor.elapsed_exclusive != anchor.elapsed_inclusive {
		percent_with_children := 100.0 * (f64(anchor.elapsed_inclusive) / f64(total_elapsed))
		fmt.printf(", %.2f%% w/children", percent_with_children)
	}
	fmt.printf(")")
	defer fmt.println()

	if anchor.processed_bytes == 0 {
		return
	}

	mb := 1024.0 * 1024.0
	gb := mb * 1024.0

	seconds := f64(anchor.elapsed_inclusive) / f64(freq)
	bytes_per_second := f64(anchor.processed_bytes) / seconds
	mb_processed := f64(anchor.processed_bytes) / mb
	gb_per_second := bytes_per_second / gb

	fmt.printf(" -> %.3fmb at %.2fgb/s", mb_processed, gb_per_second)
}
