package main

import "../metrics"
import "base:intrinsics"
import "core:fmt"
import "core:os"

begin_time :: proc(t: ^tester) {
	t.open_blocks += 1
	t.accumulator[properties.page_faults] -= u64(metrics.read_page_faults())
	t.accumulator[properties.time] -= u64(intrinsics.read_cycle_counter())
}

count_bytes :: proc(t: ^tester, bytes: u64) {
	t.accumulator[properties.bytes] = u64(bytes)
}

end_time :: proc(t: ^tester, bytes: u64) {
	t.closed_blocks += 1
	t.accumulator[properties.time] += u64(intrinsics.read_cycle_counter())
	t.accumulator[properties.page_faults] += u64(metrics.read_page_faults())

	if t.target_processed_bytes == 0 {
		count_bytes(t, bytes)
	}
}

error :: proc(t: ^tester, msg: string) {
	t.mode = .errored
	fmt.fprintf(os.stderr, "ERROR: %s\n", msg)
}

is_testing :: proc(t: ^tester) -> bool {
	if t.mode != .testing {
		return false
	}
	current_time := intrinsics.read_cycle_counter()
	update_results(t, current_time)

	if current_time - t.started_at > t.try_for {
		t.mode = .completed
		fmt.printf("                                                          \r")
		print_results(t.results, t.cpu_freq, t.target_processed_bytes)
	}

	return t.mode == .testing
}

print_metric :: proc(label: string, metric: repetition_metric, cpu_freq: i64) {
	count := metric[properties.test_count]
	divisor := count != 0 ? f64(count) : 1.0

	calculated: [properties]f64
	for m in properties {
		calculated[m] = f64(metric[m]) / divisor
	}

	fmt.printf("%s: %.0f", label, calculated[properties.time])
	if cpu_freq == 0 {
		return
	}

	seconds := seconds_from_cpu_time(calculated[properties.time], cpu_freq)
	fmt.printf(" (%fms)", 1000.0 * seconds)

	if calculated[properties.bytes] == 0 {
		return
	}

	gb := 1024.0 * 1024.0 * 1024.0
	best_bandwidth := f64(calculated[properties.bytes]) / (gb * seconds)
	fmt.printf(" -> %fgb/s", best_bandwidth)

	if calculated[properties.page_faults] == 0 {
		return
	}

	fmt.printf(
		" PF: %0.4f (%0.4fk/fault)",
		calculated[properties.page_faults],
		calculated[properties.bytes] / (calculated[properties.page_faults] * 1024.0),
	)
}


print_results :: proc(results: test_results, cpu_freq, processed_bytes: i64) {
	print_metric("Min", results.min, cpu_freq)
	fmt.println()

	print_metric("Max", results.max, cpu_freq)
	fmt.println()

	print_metric("Avg", results.total, cpu_freq)
	fmt.println()
}

seconds_from_cpu_time :: proc(cpu_time: f64, cpu_freq: i64) -> f64 {
	if cpu_freq == 0 {
		return 0.0
	}

	return cpu_time / f64(cpu_freq)
}

start_wave :: proc(t: ^tester, cpu_freq: i64, seconds_to_try_for: i64 = 10) {
	if t.mode == .uninitialized {
		t.mode = .testing
		t.cpu_freq = cpu_freq
		t.results.min[properties.time] -= 1
	} else if t.mode == .completed {
		t.mode = .testing
		if t.cpu_freq != cpu_freq {
			error(t, "cpu freq changed")
		}
	}

	t.try_for = seconds_to_try_for * cpu_freq
	t.started_at = intrinsics.read_cycle_counter()
}

update_results :: proc(t: ^tester, current_time: i64) {
	if t.open_blocks == 0 {
		return
	}

	if t.open_blocks != t.closed_blocks {
		error(t, "unbalanced open & close blocks")
		return
	}

	if t.accumulator[properties.bytes] != u64(t.target_processed_bytes) {
		error(t, "did not process correct bytes")
		return
	}

	results := &t.results
	t.accumulator[properties.test_count] = 1

	if results.max[properties.time] < t.accumulator[properties.time] {
		results.max = t.accumulator
	}

	if results.min[properties.time] > t.accumulator[properties.time] {
		results.min = t.accumulator
		t.started_at = current_time
		print_metric("Min", results.min, t.cpu_freq)
		fmt.printf("                                   \r")
	}

	for metric in properties {
		results.total[metric] += t.accumulator[metric]
		t.accumulator[metric] = 0

	}

	t.closed_blocks = 0
	t.open_blocks = 0
}
