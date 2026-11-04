package metrics

profiler :: struct {
	anchor_index: int,
	start:        i64,
	anchors:      [4096]anchor,
}

anchor :: struct {
	parent_index:      int, // 4 bytes
	start:             i64, // 8 bytes
	elapsed_inclusive: i64,
	elapsed_exclusive: i64,
	hits:              i64,
	label:             string, // 16 bytes
}
