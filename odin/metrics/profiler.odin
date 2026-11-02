package metrics

import "base:intrinsics"
import "core:fmt"

global_profiler: profiler

@(deferred_in = end_profile_block)
profile :: proc(label: string) {
	global_profiler.anchors[global_profiler.anchor_index].start = intrinsics.read_cycle_counter()
}


end_profile_block :: proc(label: string) {
	global_profiler.anchors[global_profiler.anchor_index].elapsed =
		intrinsics.read_cycle_counter() -
		global_profiler.anchors[global_profiler.anchor_index].start
	global_profiler.anchors[global_profiler.anchor_index].hits += 1
	global_profiler.anchors[global_profiler.anchor_index].label = label
	global_profiler.anchor_index += 1
}

@(deferred_none = end_profiler)
begin_profiler :: proc() {
	global_profiler.start = intrinsics.read_cycle_counter()
}

end_profiler :: proc() {
	elapsed := intrinsics.read_cycle_counter() - global_profiler.start

	fmt.printfln("\nTotal ticks: %d", elapsed)

	cpu_freq := intrinsics.read_cycle_counter_frequency()
	fmt.printf(
		"Total time: %0.4fms (CPU freq %d)\n",
		1000.0 * f64(elapsed) / f64(cpu_freq),
		cpu_freq,
	)

	for i in 0 ..< global_profiler.anchor_index {
		anchor := global_profiler.anchors[i]
		print_time_elapsed(anchor.label, elapsed, anchor.elapsed, anchor.hits)
	}
}
