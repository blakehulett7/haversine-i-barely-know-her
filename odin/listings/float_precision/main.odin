package main

import "core:fmt"
import "core:math"
import "core:math/rand"

main :: proc() {
	for i in 0 ..< 10 {
		f := rand.float64()
		asin := math.asin(f)
		sqrt := math.sqrt(f)

		fmt.printfln("--- %.17f ---", f)
		fmt.printfln("\tasin: %.17f", asin)
		fmt.printfln("\tsqrt: %.17f", sqrt)
	}

	fmt.println("\n--- cos ---")
	for i in 0 ..< 10 {
		f := rand.float64_range(-1.571, 1.571)
		cos := math.cos(f)
		fmt.printfln("\t%.17f: %.17f", f, cos)
	}

	fmt.println("\n--- sin ---")
	for i in 0 ..< 10 {
		f := rand.float64_range(-3.142, 3.142)
		sin := math.sin(f)
		fmt.printfln("\t%.17f: %.17f", f, sin)
	}

}
