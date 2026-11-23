package main

import "../../generator"

repetition_test :: struct {
	name: string,
	func: haversine_func,
}

test_func :: proc(x0, y0, x1, y1: f64) -> f64
haversine_func :: proc(pairs: []generator.Pair) -> f64
