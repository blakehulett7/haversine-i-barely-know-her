package bath

import "core:fmt"

print :: proc(t: ^domain_tracker) {
	fmt.println("--- range tracker ---")
	fmt.println("asin")
	fmt.printfln("\tmin: %f", t.asin.min)
	fmt.printfln("\tmax: %f", t.asin.max)
	fmt.println("cos")
	fmt.printfln("\tmin: %f", t.cos.min)
	fmt.printfln("\tmax: %f", t.cos.max)
	fmt.println("sin")
	fmt.printfln("\tmin: %f", t.sin.min)
	fmt.printfln("\tmax: %f", t.sin.max)
	fmt.println("sqrt")
	fmt.printfln("\tmin: %f", t.sqrt.min)
	fmt.printfln("\tmax: %f", t.sqrt.max)
	move_cursor_up(13)
}

move_cursor_up :: proc(n: int) {
	fmt.printf("\x1b[%dA", n)
}
