package metrics

import "base:intrinsics"
import "core:fmt"

read_cpu_timer :: proc() -> u64 {
	return u64(intrinsics.read_cycle_counter())
}

// NOTE: On modern Apple silicon, this will always be 1GHz -- I still include this because it is 1 asm instruction and guarantees backward compatibility
read_cpu_frequency :: proc() -> u64 {
	return u64(intrinsics.read_cycle_counter_frequency())
}

estimate_cpu_frequency :: proc() {
	milliseconds_to_wait: u64 = 1000

	os_freq := get_os_time_freq()
	fmt.printfln("    OS Freq: %d", os_freq)

	cpu_start := read_cpu_timer()
	os_start := read_os_timer()
	os_end: u64
	os_elapsed: u64
	os_wait_time := os_freq * milliseconds_to_wait / 1000
	for os_elapsed < os_wait_time {
		os_end = read_os_timer()
		os_elapsed = os_end - os_start
	}

	cpu_end := read_cpu_timer()
	cpu_elapsed := cpu_end - cpu_start
	cpu_frequency: u64
	cpu_frequency = os_freq * cpu_elapsed / os_elapsed

	fmt.printf("   OS Timer: %d -> %d = %d elapsed\n", os_start, os_end, os_elapsed)
	fmt.printf(" OS Seconds: %.4f\n", f64(os_elapsed) / f64(os_freq))
	fmt.printf("  CPU Timer: %d -> %d = %d elapsed\n", cpu_start, cpu_end, cpu_elapsed)
	fmt.printf("   CPU Freq: %d (guessed)\n", cpu_frequency)
	fmt.printfln("actual cpu freq: %d", nanoseconds_to_seconds(read_cpu_frequency()))
}

nanoseconds_to_seconds :: proc(ns: u64) -> u64 {
	return ns / 1000000000
}
