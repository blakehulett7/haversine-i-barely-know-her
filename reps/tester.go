package main

import "time"

type f64 = float64
type u64 = uint64

type Tester struct {
	Max time.Duration
	Min time.Duration

	test_count u64
	total_time time.Duration

	bytes_processed u64
	expected_bytes  u64
	test_for        time.Duration

	min_bytes_processed u64
	max_bytes_processed u64

	run_timer  time.Time
	started_at time.Time
}

func New(test_for time.Duration) *Tester {
	return &Tester{
		test_for: test_for,
	}
}
