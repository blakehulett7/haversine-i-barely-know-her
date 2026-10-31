package metrics

import "core:fmt"
foreign import libsystem "system:System.framework"

mach_timebase_info_data_t :: struct {
	numer: u32,
	denom: u32,
}

foreign libsystem {
	mach_absolute_time :: proc() -> u64 ---
	mach_timebase_info :: proc(info: ^mach_timebase_info_data_t) -> i32 ---
}

os_time_main :: proc() {
	freq := get_os_time_freq()
	fmt.printfln("    OS Freq: %d", freq)

	start := read_os_timer()
	end: u64
	elapsed: u64
	for elapsed < freq {
		end = read_os_timer()
		elapsed = end - start
	}

	fmt.printf("   OS Timer: %d -> %d = %d elapsed\n", start, end, elapsed)
	fmt.printf(" OS Seconds: %.4f\n", f64(elapsed) / f64(freq))
}

get_os_time_freq :: proc() -> u64 {
	info: mach_timebase_info_data_t
	mach_timebase_info(&info)
	return u64(info.numer) / u64(info.denom)
}

read_os_timer :: proc() -> u64 {
	return mach_absolute_time()
}

os_time_test :: proc() {
	info: mach_timebase_info_data_t
	mach_timebase_info(&info)

	start := mach_absolute_time()

	end := mach_absolute_time()

	elapsed_ticks := end - start
	elapsed_ns := (elapsed_ticks * u64(info.numer)) / u64(info.denom)
	fmt.printf("Elapsed time: %d ns\n", elapsed_ns)
}
