package metrics

profiler :: struct {
	start:        i64,
	anchor_index: int,
	anchors:      [4096]anchor,
}

anchor :: struct {
	elapsed: i64,
	hits:    i64,
	label:   string,
}
