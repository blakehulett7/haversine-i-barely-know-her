package metrics

profiler :: struct {
	anchor_index: int,
	start:        i64,
	anchors:      [4096]anchor,
}

anchor :: struct {
	elapsed_inclusive: i64,
	elapsed_exclusive: i64,
	hits:              i64,
	processed_bytes:   u64,
	label:             string, // 16 bytes
}
