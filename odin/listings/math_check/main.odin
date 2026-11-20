package main

import "../../scratch/bath"
import "base:intrinsics"
import "core:fmt"
import "core:math"

Half_PI :: math.PI / 2.0
Max_Arcsine_Range :: 1.0 / intrinsics.sqrt(2.0)
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

	fmt.println("\n--- Sine (Taylor) ---")
	for t in arbitrary_sine_tests {
		fmt.printf("Depth %s: ", t.sine_name)
		max_err, input := bath.test_math_arbitrary(0, Half_PI, math.sin_f64, bath.sin_v4, t.power)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println("\n--- Sine (Horner) ---")
	for t in arbitrary_sine_tests {
		fmt.printf("Depth %s: ", t.sine_name)
		max_err, input := bath.test_math_arbitrary(
			0,
			Half_PI,
			math.sin_f64,
			bath.horner_sine,
			t.power,
		)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println("\n--- Sine (Fused_Horner) ---")
	for t in arbitrary_sine_tests {
		fmt.printf("Depth %s: ", t.sine_name)
		max_err, input := bath.test_math_arbitrary(
			0,
			Half_PI,
			math.sin_f64,
			bath.horner_sine_fused,
			t.power,
		)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println("\n--- Sine (Static_Horner) ---")
	for t in arbitrary_sine_tests {
		fmt.printf("Depth %s: ", t.sine_name)
		max_err, input := bath.test_math_arbitrary(
			0,
			Half_PI,
			math.sin_f64,
			bath.horner_sine_static,
			t.power,
		)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println("\n--- Sine (Minimax) ---")
	max_terms := 11
	for i in 2 ..= max_terms {
		fmt.printf("Depth %d: ", i)
		max_err, input := bath.test_math_arbitrary(
			0,
			Half_PI,
			math.sin_f64,
			bath.minimax_sine_static,
			i,
		)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println("\n--- Sine (Minimax_Unrolled) ---")
	fmt.printf("Depth %d: ", 9)
	max_err, input := bath.test_math(0, Half_PI, math.sin_f64, bath.sine)
	fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)

	fmt.println("\n--- ArcSine (Minimax_In_Range) ---")
	max_terms = 22
	for i in 2 ..= max_terms {
		fmt.printf("Depth %d: ", i)
		max_err, input := bath.test_math_arbitrary(
			0,
			Max_Arcsine_Range,
			math.asin,
			bath.minimax_arcsine_static,
			i,
		)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}

	fmt.println("\n--- ArcSine (Minimax_Full_Range) ---")
	max_terms = 22
	for i in 2 ..= max_terms {
		fmt.printf("Depth %d: ", i)
		max_err, input := bath.test_math_arbitrary(0, 1, math.asin, bath.minimax_arcsine_static, i)
		fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)
	}


	fmt.println("\n--- ArcSine (Minimax_Unrolled_In_Range) ---")
	fmt.printf("Depth %d: ", 19)
	max_err, input = bath.test_math(0, Max_Arcsine_Range, math.asin, bath.minimax_arcsine_unrolled)
	fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)

	fmt.println("\n--- ArcSine (Minimax_Unrolled_Full_Range) ---")
	fmt.printf("Depth %d: ", 19)
	max_err, input = bath.test_math(0, 1, math.asin, bath.asine)
	fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)

	fmt.println()
}
