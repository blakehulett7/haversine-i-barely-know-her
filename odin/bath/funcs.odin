package bath

import "base:intrinsics"
import "core:fmt"
import "core:math"

a: f64 = -4.0 / (math.PI * math.PI)
b: f64 = 4.0 / math.PI
Half_PI: f64 = math.PI / 2.0

domain_tracker :: struct {
	asin: domain,
	cos:  domain,
	sin:  domain,
	sqrt: domain,
}

domain :: struct {
	initialized: bool,
	max:         f64,
	min:         f64,
}

asin :: proc(t: ^domain_tracker, x: f64) -> f64 {
	domain := &t.asin
	track(domain, x)
	return math.asin(x)
}

cos :: proc(x: f64) -> f64 {
	return sin_v3(x + Half_PI)
}

cos_v2 :: proc(x: f64, power: int) -> f64 {
	return sin_v5(x + Half_PI, power)
}

cos_tracker :: proc(t: ^domain_tracker, x: f64) -> f64 {
	domain := &t.cos
	track(domain, x)
	return math.cos(x)
}

factorial :: proc(x: int) -> f64 {
	res := x
	for i := x; i > 0; i -= 1 {
		res *= i
	}
	return f64(res)
}

pow :: proc(x: f64, pow: int) -> f64 {
	res: f64 = 1.0
	for i in 0 ..< pow {
		res *= x
	}
	return res
}

sin_v1 :: proc(x: f64) -> f64 {
	return a * x * x + b * x
}

sin_v2 :: proc(x: f64) -> f64 {
	num := sin_v1(math.abs(x))
	return x < 0 ? -num : num
}

sin_v3 :: proc(x: f64) -> f64 {
	pos := math.abs(x)
	quarter_x := pos > Half_PI ? math.PI - pos : pos
	num := sin_v1(quarter_x)

	return x < 0 ? -num : num
}

sin_v4 :: proc(x: f64, power: int) -> f64 {
	exponent := power
	if exponent % 2 != 0 {
		exponent -= 1
	}

	res: f64 = 0.0
	should_add := true
	for i := 1; i <= exponent; i += 2 {
		calc := (pow(x, i)) / (factorial(i))
		calc = should_add ? calc : -calc
		res += calc
		should_add = !should_add
	}

	return res
}

sin_v5 :: proc(x: f64, power: int) -> f64 {
	pos := math.abs(x)
	quarter_x := pos > Half_PI ? math.PI - pos : pos
	num := sin_v4(quarter_x, power)

	return x < 0 ? -num : num
}


sin_tracker :: proc(t: ^domain_tracker, x: f64) -> f64 {
	domain := &t.sin
	track(domain, x)
	return math.sin(x)
}

sqrt :: proc(x: f64) -> f64 {
	return intrinsics.sqrt(x)
}

sqrt_tracker :: proc(t: ^domain_tracker, x: f64) -> f64 {
	domain := &t.sqrt
	track(domain, x)
	return math.sqrt(x)
}

track :: proc(domain: ^domain, x: f64) {
	if !domain.initialized {
		domain.initialized = true
		domain.max = x
		domain.min = x
		return
	}

	if x < domain.min do domain.min = x
	if x > domain.max do domain.max = x
	return
}
