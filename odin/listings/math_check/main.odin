package main

import "../../bath"
import "core:fmt"
import "core:math"

Half_PI :: math.PI / 2.0

Max_Depth :: 31

math_test :: struct {
	name:  string,
	min_x: f64,
	func:  proc(x: f64) -> f64,
}

taylor_test :: struct {
	cos_name:  string,
	sine_name: string,
	power:     int,
}

main :: proc() {
	sine_tests := [?]math_test {
		{name = "v1 + only", min_x = 0, func = bath.sin_v1},
		{name = "v1 all", min_x = -math.PI, func = bath.sin_v1},
		{name = "v2 + only", min_x = 0, func = bath.sin_v2},
		{name = "v2 all", min_x = -math.PI, func = bath.sin_v2},
		{name = "v3 + only", min_x = 0, func = bath.sin_v3},
		{name = "v3 all", min_x = -math.PI, func = bath.sin_v3},
	}

	cos_tests := [?]math_test {
		{name = "cos + only", min_x = 0, func = bath.cos},
		{name = "cos all", min_x = -Half_PI, func = bath.cos},
	}

	arbitrary_sine_tests := [(Max_Depth + 1) / 2]taylor_test{}
	for _, i in arbitrary_sine_tests {
		depth := 1 + 2 * i
		arbitrary_sine_tests[i] = {
			cos_name  = fmt.aprintf("cos depth %d", depth),
			sine_name = fmt.aprintf("sine depth %d", depth),
			power     = depth,
		}
	}

	for t in sine_tests {
		fmt.printfln("\n--- %s ---", t.name)
		max_err, input := bath.test_math(t.min_x, math.PI, math.sin_f64, t.func)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	for t in cos_tests {
		fmt.printfln("\n--- %s ---", t.name)
		max_err, input := bath.test_math(t.min_x, Half_PI, math.cos_f64, t.func)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println("\n--- Sine ---")
	for t in arbitrary_sine_tests {
		fmt.printf("Depth %s: ", t.sine_name)
		max_err, input := bath.test_math_arbitrary(
			-math.PI,
			math.PI,
			math.sin_f64,
			bath.sin_v5,
			t.power,
		)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println("\n--- Cos ---")
	for t in arbitrary_sine_tests {
		fmt.printf("Depth %s: ", t.cos_name)
		max_err, input := bath.test_math_arbitrary(0, Half_PI, math.cos_f64, bath.cos_v2, t.power)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println()
}
