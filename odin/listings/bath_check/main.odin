package main

import "../../bath"
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
	fmt.println("\n--- ArcSine ---")
	fmt.printf("Depth %d: ", 19)
	max_err, input := bath.test_math(0, 1, math.asin, bath.asine)
	fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)

	fmt.println("\n--- Cos ---")
	fmt.printf("Depth %d: ", 9)
	max_err, input = bath.test_math(-Half_PI, Half_PI, math.cos, bath.cos)
	fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)

	fmt.println("\n--- Sine ---")
	fmt.printf("Depth %d: ", 9)
	max_err, input = bath.test_math(-math.PI, math.PI, math.sin, bath.sine)
	fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)

	fmt.println("\n--- Sqrt ---")
	fmt.print("Depth chip: ")
	max_err, input = bath.test_math(0, 1, math.sqrt, bath.sqrt)
	fmt.printfln("f(%.17f) -> max err: %.17f", input, max_err)

	fmt.println()
}
