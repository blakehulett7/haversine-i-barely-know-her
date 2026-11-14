package bath

import "core:math"
import "core:math/rand"

tester :: struct {
	max_error: f64,
}

math_func :: proc(x: f64) -> f64

test_math :: proc(min_x, max_x: f64, baseline_func, optimized_func: math_func) -> f64 {
	max_err := 0.0

	for i in 0 ..< 1000000 {
		f := rand.float64_range(min_x, max_x)
		expected := baseline_func(f)
		actual := optimized_func(f)
		err := math.abs(expected - actual)

		if err > max_err {
			max_err = err
		}
	}

	return max_err
}
