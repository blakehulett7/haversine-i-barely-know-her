package metrics

import "base:intrinsics"
import "core:fmt"

ENABLE_PROFILER :: #config(PROF, false)

global_profiler: profiler
global_parent: int

@(deferred_out = end_profile_block)
profile :: proc(label: string) -> (start: i64, idx, parent_idx: int) {
	when !ENABLE_PROFILER {
		return 0, 0, 0
	}

	anchor_index := get_label_index(label)

	parent_idx = global_parent
	global_profiler.anchors[anchor_index].label = label
	global_parent = anchor_index

	return intrinsics.read_cycle_counter(), anchor_index, parent_idx
}

end_profile_block :: proc(start: i64, idx, parent_idx: int) {
	when !ENABLE_PROFILER {
		return
	}

	elapsed := intrinsics.read_cycle_counter() - start
	anchor := &global_profiler.anchors[idx]
	parent := &global_profiler.anchors[parent_idx]
	global_parent = parent_idx

	parent.elapsed_exclusive -= elapsed
	anchor.elapsed_exclusive += elapsed
	anchor.elapsed_inclusive = elapsed
	anchor.hits += 1
}

@(deferred_none = end_profiler)
begin_profiler :: proc() {
	global_profiler.start = intrinsics.read_cycle_counter()
}

end_profiler :: proc() {
	elapsed := intrinsics.read_cycle_counter() - global_profiler.start

	fmt.printfln("\nTotal ticks: %d", elapsed)

	cpu_freq := read_freq()
	fmt.printf(
		"Total time: %0.4fms (CPU freq %d)\n",
		1000.0 * f64(elapsed) / f64(cpu_freq),
		cpu_freq,
	)

	if !ENABLE_PROFILER {
		return
	}

	for i in 1 ..< global_profiler.anchor_index {
		anchor := global_profiler.anchors[i]
		print_time_elapsed(anchor.label, elapsed, anchor)
	}
}

get_label_index :: proc(label: string) -> int {
	// NOTE: Take this for loop out if we don't want anchor aggregation & recursion support in exchange for faster performance
	for i in 1 ..= global_profiler.anchor_index {
		if global_profiler.anchors[i].label == label {
			return i
		}
	}

	global_profiler.anchor_index += 1
	return global_profiler.anchor_index
}
