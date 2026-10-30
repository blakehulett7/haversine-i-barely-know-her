package metrics

import "../perform"
import "core:fmt"
foreign import libsystem "System.framework"

mach_timebase_info_data_t :: struct {
	numer: u32,
	denom: u32,
}

foreign libsystem {
	mach_absolute_time :: proc() -> u64 ---
	mach_timebase_info :: proc(info: ^mach_timebase_info_data_t) -> i32 ---
}

os_time_test :: proc() {
	info: mach_timebase_info_data_t
	mach_timebase_info(&info)

	start := mach_absolute_time()

	perform.work("data/pairs.json")

	end := mach_absolute_time()

	elapsed_ticks := end - start
	elapsed_ns := (elapsed_ticks * u64(info.numer)) / u64(info.denom)
	fmt.printf("Elapsed time: %d ns\n", elapsed_ns)
}
