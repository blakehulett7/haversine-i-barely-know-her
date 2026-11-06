package main

test_mode :: enum {
	uninitialized,
	testing,
	completed,
	errored,
}

test_results :: struct {
	max_time:   u64,
	min_time:   u64,
	test_count: u64,
	total_time: u64,
}

tester :: struct {
	mode:                   test_mode,
	closed_blocks:          u32,
	open_blocks:            u32,
	cpu_freq:               i64,
	bytes_accumulated:      i64,
	started_at:             i64,
	target_processed_bytes: i64,
	time_accumulated:       u64,
	try_for:                i64,
	results:                test_results,
}
