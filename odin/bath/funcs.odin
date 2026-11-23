package bath

import "base:intrinsics"
import "core:math"

Half_PI: f64 = math.PI / 2.0
Max_ArcSine: f64 = 1.0 / sqrt(2.0)
Max_ArcSine_Squared: f64 = Max_ArcSine * Max_ArcSine

asine :: proc "contextless" (x: f64) -> f64 {
	if x <= Max_ArcSine {
		return minimax_arcsine_unrolled(x)
	}

	x2 := x * x
	shifted_x := sqrt(1 - x2)
	core := minimax_arcsine_unrolled(shifted_x)
	return Half_PI - core
}

cos :: proc "contextless" (x: f64) -> f64 {
	return sine(x + Half_PI)
}

@(private)
minimax_arcsine_unrolled :: proc "contextless" (x: f64) -> f64 {
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

minimax_arcsine_unrolled_from_squared :: proc "contextless" (x2: f64) -> f64 {
	x := sqrt(x2)

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


@(private)
minimax_sine_unrolled :: proc "contextless" (x: f64) -> f64 {
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

sine :: proc "contextless" (x: f64) -> f64 {
	pos := math.abs(x)
	quarter_x := pos > Half_PI ? math.PI - pos : pos
	num := minimax_sine_unrolled(quarter_x)

	return x < 0 ? -num : num
}

sqrt :: proc "contextless" (x: f64) -> f64 {
	return intrinsics.sqrt(x)
}
