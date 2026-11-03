package metrics

profiler :: struct {
	start:        i64,
	anchor_index: int,
	anchors:      [4096]anchor,
}

anchor :: struct {
	parent_index:      int,
	start:             i64,
	elapsed_inclusive: i64,
	elapsed_exclusive: i64,
	hits:              i64,
	label:             string,
}
