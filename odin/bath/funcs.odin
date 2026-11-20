package bath

import "base:intrinsics"
import "core:math"

a: f64 = -4.0 / (math.PI * math.PI)
b: f64 = 4.0 / math.PI
Half_PI: f64 = math.PI / 2.0
Max_ArcSine: f64 = 1.0 / math.sqrt(2.0)

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

asine :: proc(x: f64) -> f64 {
	if x <= Max_ArcSine {
		return minimax_arcsine_unrolled(x)
	}

	x2 := x * x
	shifted_x := sqrt(1 - x2)
	core := minimax_arcsine_unrolled(shifted_x)
	return Half_PI - core
}

asin_tracker :: proc(t: ^domain_tracker, x: f64) -> f64 {
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

minimax_arcsine_static :: proc(x: f64, terms: int) -> f64 {
	x2 := x * x

	res := ArcsineRadians_Dmitri[terms][terms - 1]
	for term := terms - 1; term > 0; term -= 1 {
		res = math.fmuladd(res, x2, ArcsineRadians_Dmitri[terms][term - 1])
	}
	return res * x
}

minimax_arcsine_unrolled :: proc(x: f64) -> f64 {
	x2 := x * x

	res := 0h3fedfc53682725ca
	res = math.fmuladd(res, x2, 0hc00bec6daf74ed61)
	res = math.fmuladd(res, x2, 0h4018bf4dadaf548c)
	res = math.fmuladd(res, x2, 0hc01b06f523e74f33)
	res = math.fmuladd(res, x2, 0h4014537ddde2d76d)
	res = math.fmuladd(res, x2, 0hc006067d334b4792)
	res = math.fmuladd(res, x2, 0h3ff1fb54da575b22)
	res = math.fmuladd(res, x2, 0hbfd57380bcd2890e)
	res = math.fmuladd(res, x2, 0h3fb69b370aad086e)
	res = math.fmuladd(res, x2, 0hbf721438ccc95d62)
	res = math.fmuladd(res, x2, 0h3f8b8a33b8e380ef)
	res = math.fmuladd(res, x2, 0h3f8c37061f4e5f55)
	res = math.fmuladd(res, x2, 0h3f91c875d6c5323d)
	res = math.fmuladd(res, x2, 0h3f96e88ce94d1149)
	res = math.fmuladd(res, x2, 0h3f9f1c73443a02f5)
	res = math.fmuladd(res, x2, 0h3fa6db6db3184756)
	res = math.fmuladd(res, x2, 0h3fb3333333380df2)
	res = math.fmuladd(res, x2, 0h3fc555555555531e)
	res = math.fmuladd(res, x2, 0h3ff0000000000000)

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
	x2 := x * x

	res := 0h3ce883c1c5deffbe
	res = math.fmuladd(res, x2, 0hbd6ae43dc9bf8ba7)
	res = math.fmuladd(res, x2, 0h3de6123ce513b09f)
	res = math.fmuladd(res, x2, 0hbe5ae6454d960ac4)
	res = math.fmuladd(res, x2, 0h3ec71de3a52aab96)
	res = math.fmuladd(res, x2, 0hbf2a01a01a014eb6)
	res = math.fmuladd(res, x2, 0h3f811111111110c9)
	res = math.fmuladd(res, x2, 0hbfc5555555555555)
	res = math.fmuladd(res, x2, 0h3ff0000000000000)

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
