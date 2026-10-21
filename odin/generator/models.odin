package generator

Pair :: struct {
	x0: f64 `json:"x0"`,
	y0: f64 `json:"y0"`,
	x1: f64 `json:"x1"`,
	y1: f64 `json:"y1"`,
}

Out :: struct {
	pairs: [dynamic]Pair,
}
