package metrics

import "base:intrinsics"
import "core:sys/posix"
import "core:time"

TIMER :: #config(TIMER, "CPU")

when TIMER == "OS" {
	read_timer :: proc() -> i64 {
		tv: posix.timeval
		posix.gettimeofday(&tv, nil)
		return i64(tv.tv_sec * 1000000000) + i64(tv.tv_usec * 1000)
	}
	read_freq :: proc() -> i64 {return 1000000000}
} else when TIMER == "GO" {
	read_timer :: proc() -> i64 {return time.now()._nsec}
	read_freq :: proc() -> i64 {return 1000000000}
} else when TIMER == "TICK" {
	read_timer :: proc() -> i64 {return time.tick_now()._nsec}
	read_freq :: proc() -> i64 {return 1000000000}
} else when TIMER == "TIME" {
	read_timer :: proc() -> i64 {return i64(time.read_cycle_counter())}
	read_freq :: proc() -> i64 {return 1000000000}
} else {
	read_timer :: proc() -> i64 {return intrinsics.read_cycle_counter()}
	read_freq :: proc() -> i64 {return intrinsics.read_cycle_counter_frequency()}
}
