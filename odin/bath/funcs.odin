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
	res := 1
	for i := x; i > 1; i -= 1 {
		res *= i
	}
	return f64(res)
}

horner_sine :: proc(x: f64, pow: int) -> f64 {
	x2 := x * x

	res := taylor_coefficient(pow)
	for exp := pow - 2; exp > 0; exp -= 2 {
		res = res * x2 + taylor_coefficient(exp)
	}
	return res * x
}

horner_sine_fused :: proc(x: f64, pow: int) -> f64 {
	x2 := x * x

	res := taylor_coefficient(pow)
	for exp := pow - 2; exp > 0; exp -= 2 {
		res = math.fmuladd(res, x2, taylor_coefficient(exp))
	}
	return res * x
}

horner_sine_static :: proc(x: f64, pow: int) -> f64 {
	x2 := x * x

	res := SineRadians_Taylor[(pow - 1) / 2]
	for exp := pow - 2; exp > 0; exp -= 2 {
		res = math.fmuladd(res, x2, SineRadians_Taylor[(exp - 1) / 2])
	}
	return res * x
}

minimax_sine_static :: proc(x: f64, terms: int) -> f64 {
	x2 := x * x

	res := SineRadians_Dmitri[terms][terms - 1]
	for term := terms - 1; term > 0; term -= 1 {
		res = math.fmuladd(res, x2, SineRadians_Dmitri[terms][term - 1])
	}
	return res * x
}

minimax_sine_unrolled :: proc(x: f64) -> f64 {
	best_depth := 9
	x2 := x * x

	res := SineRadians_Dmitri[best_depth][8]
	res = math.fmuladd(res, x2, SineRadians_Dmitri[best_depth][7])
	res = math.fmuladd(res, x2, SineRadians_Dmitri[best_depth][6])
	res = math.fmuladd(res, x2, SineRadians_Dmitri[best_depth][5])
	res = math.fmuladd(res, x2, SineRadians_Dmitri[best_depth][4])
	res = math.fmuladd(res, x2, SineRadians_Dmitri[best_depth][3])
	res = math.fmuladd(res, x2, SineRadians_Dmitri[best_depth][2])
	res = math.fmuladd(res, x2, SineRadians_Dmitri[best_depth][1])
	res = math.fmuladd(res, x2, SineRadians_Dmitri[best_depth][0])

	return res * x
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
	res: f64 = 0.0
	x2 := x * x
	x_pow := x

	for i := 1; i <= power; i += 2 {
		res += x_pow * taylor_coefficient(i)
		x_pow *= x2
	}

	return res
}

sin_v5 :: proc(x: f64, power: int) -> f64 {
	pos := math.abs(x)
	quarter_x := pos > Half_PI ? math.PI - pos : pos
	num := sin_v4(quarter_x, power)

	return x < 0 ? -num : num
}

sin_v6 :: proc(x: f64, power: int) -> f64 {
	pos := math.abs(x)
	quarter_x := pos > Half_PI ? math.PI - pos : pos
	num := horner_sine(quarter_x, power)

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

taylor_coefficient :: proc(x: int) -> f64 {
	sign := ((x - 1) / 2) % 2 == 0 ? 1.0 : -1.0
	return sign / factorial(x)
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
