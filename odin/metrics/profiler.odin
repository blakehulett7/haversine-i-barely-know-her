package metrics

import "base:intrinsics"
import "core:fmt"

global_profiler: profiler

profile :: proc(func: proc() -> $T, label := #caller_expression(func)) -> T {
	start := intrinsics.read_cycle_counter()
	result := func()
	elapsed := intrinsics.read_cycle_counter() - start

	anchor := global_profiler.anchors[global_profiler.anchor_index]

	anchor.elapsed += elapsed
	anchor.hits += 1
	anchor.label = label

	global_profiler.anchor_index += 1

	return result
}

begin_profiler :: proc() {
	global_profiler.start = intrinsics.read_cycle_counter()
}

end_profiler :: proc() {
	elapsed := global_profiler.start - intrinsics.read_cycle_counter()

	cpu_freq := intrinsics.read_cycle_counter_frequency()
	fmt.printf(
		"Total time: %0.4fms (CPU freq %d)\n",
		1000.0 * f64(elapsed) / f64(cpu_freq),
		cpu_freq,
	)

	for i in 0 ..= global_profiler.anchor_index {
		anchor := global_profiler.anchors[i]
		print_time_elapsed(anchor.label, elapsed, anchor.elapsed, anchor.hits)
	}
}
