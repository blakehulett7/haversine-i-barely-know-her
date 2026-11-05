package metrics

add_bandwith_data :: proc(anchor_index: int, processed_bytes: u64) {
	global_profiler.anchors[anchor_index].processed_bytes += processed_bytes
}
