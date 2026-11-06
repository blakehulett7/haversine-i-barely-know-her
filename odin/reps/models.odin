package main

properties :: enum {
	test_count,
	bytes,
	page_faults,
	time,
}

repetition_metric :: [properties]u64

test_mode :: enum {
	uninitialized,
	testing,
	completed,
	errored,
}

test_results :: struct {
	max:   repetition_metric,
	min:   repetition_metric,
	total: repetition_metric,
}

tester :: struct {
	mode:                   test_mode,
	closed_blocks:          u32,
	open_blocks:            u32,
	cpu_freq:               i64,
	started_at:             i64,
	target_processed_bytes: i64,
	try_for:                i64,
	accumulator:            repetition_metric,
	results:                test_results,
}
