package generator

import "core:encoding/json"
import "core:os"

Error :: union #shared_nil {
	json.Marshal_Error,
	os.Error,
}

Pair :: struct {
	x0: f64 `json:"x0"`,
	y0: f64 `json:"y0"`,
	x1: f64 `json:"x1"`,
	y1: f64 `json:"y1"`,
}

Out :: struct {
	answer: f64,
	seed:   u64,
	pairs:  [dynamic]Pair,
}
