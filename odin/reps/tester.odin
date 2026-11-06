package main

import "base:intrinsics"
import "core:fmt"
import "core:os"

begin_time :: proc(t: ^tester) {
	t.open_blocks += 1
	t.time_accumulated -= u64(intrinsics.read_cycle_counter())
}

count_bytes :: proc(t: ^tester, bytes: i64) {
	t.bytes_accumulated = bytes
}

end_time :: proc(t: ^tester, bytes: i64) {
	t.closed_blocks += 1
	t.time_accumulated += u64(intrinsics.read_cycle_counter())
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

print_results :: proc(results: test_results, cpu_freq, processed_bytes: i64) {
	print_time("Min", results.min_time, cpu_freq, processed_bytes)
	fmt.println()

	print_time("Max", results.max_time, cpu_freq, processed_bytes)
	fmt.println()

	if results.test_count == 0 {
		return
	}
	print_time("Avg", f64(results.total_time) / f64(results.test_count), cpu_freq, processed_bytes)
	fmt.println()
}

print_time :: proc {
	print_time_f64,
	print_time_u64,
}

print_time_f64 :: proc(label: string, cpu_time: f64, cpu_freq, processed_bytes: i64) {
	fmt.printf("%s: %.0f", label, cpu_time)

	if cpu_freq == 0 {
		return
	}

	seconds := seconds_from_cpu_time(cpu_time, cpu_freq)
	fmt.printf(" (%fms)", 1000.0 * seconds)

	if processed_bytes == 0 {
		return
	}

	gb := 1024.0 * 1024.0 * 1024.0
	best_bandwidth := f64(processed_bytes) / (gb * seconds)
	fmt.printf(" %fgb/s", best_bandwidth)
}

print_time_u64 :: proc(label: string, time: u64, cpu_freq, processed_bytes: i64) {
	print_time_f64(label, f64(time), cpu_freq, processed_bytes)
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
		t.results.min_time -= 1
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

	if t.bytes_accumulated != t.target_processed_bytes {
		error(t, "did not process correct bytes")
		return
	}

	results := &t.results
	results.test_count += 1
	results.total_time += t.time_accumulated

	if results.max_time < t.time_accumulated {
		results.max_time = t.time_accumulated
	}

	if results.min_time > t.time_accumulated {
		results.min_time = t.time_accumulated
		t.started_at = current_time
		print_time("Min", results.min_time, t.cpu_freq, t.bytes_accumulated)
		fmt.printf("               \r")
	}

	t.bytes_accumulated = 0
	t.closed_blocks = 0
	t.open_blocks = 0
	t.time_accumulated = 0
}
