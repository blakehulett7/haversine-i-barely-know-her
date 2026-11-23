package reps

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
