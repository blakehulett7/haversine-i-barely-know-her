package metrics

import "base:intrinsics"
import "core:fmt"

global_profiler: profiler
global_parent: int

@(deferred_in_out = end_profile_block)
profile :: proc(label: string) -> int {
	anchor_index := get_label_index(label)

	global_profiler.anchors[anchor_index].start = intrinsics.read_cycle_counter()
	global_profiler.anchors[anchor_index].parent_index = global_parent
	global_parent = anchor_index

	return global_parent
}


end_profile_block :: proc(label: string, idx: int) {
	anchor := &global_profiler.anchors[idx]
	parent := &global_profiler.anchors[anchor.parent_index]
	elapsed := intrinsics.read_cycle_counter() - anchor.start

	global_parent = anchor.parent_index
	parent.elapsed_children += elapsed

	anchor.elapsed += elapsed
	anchor.hits += 1
	anchor.label = label
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

	for i in 1 ..< global_profiler.anchor_index {
		anchor := global_profiler.anchors[i]
		print_time_elapsed(anchor.label, elapsed, anchor)
	}
}

get_label_index :: proc(label: string) -> int {
	// NOTE: Take this for loop out if we don't want anchor aggregation
	for i in 0 ..< global_profiler.anchor_index {
		if global_profiler.anchors[i].label == label {
			return i
		}
	}

	global_profiler.anchor_index += 1
	return global_profiler.anchor_index
}
