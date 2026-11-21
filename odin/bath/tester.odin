package bath

import "core:math"
import "core:math/rand"

tester :: struct {
	max_error: f64,
}

math_lib_func :: proc "contextless" (x: f64) -> f64

test_math :: proc(
	min_x, max_x: f64,
	baseline_func: math_lib_func,
	optimized_func: math_lib_func,
) -> (
	max_err, input: f64,
) {
	for i in 0 ..< 1000000 {
		f := rand.float64_range(min_x, max_x)
		expected := baseline_func(f)
		actual := optimized_func(f)
		err := math.abs(expected - actual)

		if err > max_err {
			input = f
			max_err = err
		}
	}

	return max_err, input
}
