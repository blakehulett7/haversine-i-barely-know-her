package bath

import "../generator"
import "core:math"

square :: proc(a: f64) -> f64 {
	result := a * a
	return result
}

radians_from_degrees :: proc(degrees: f64) -> f64 {
	result := 0.01745329251994329577 * degrees
	return result
}

earth_radius :: 6372.8
Double_Earth_Radius :: 2.0 * earth_radius
Rad_converter :: 0.01745329251994329577
Half_rad_converter :: Rad_converter / 2

haversine :: proc(x0, y0, x1, y1: f64) -> f64 {
	lat1 := x0
	lat2 := x1
	lon1 := y0
	lon2 := y1

	dLat := radians_from_degrees(lat2 - lat1)
	dLon := radians_from_degrees(lon2 - lon1)
	lat1 = radians_from_degrees(lat1)
	lat2 = radians_from_degrees(lat2)

	a := square(sine(dLat / 2.0)) + cos(lat1) * cos(lat2) * square(sine(dLon / 2))
	c := 2.0 * asine(sqrt(a))
	result := earth_radius * c

	return result
}

expanded_haversine :: proc(pairs: []generator.Pair) -> f64 {
	sum: f64
	for pair in pairs {
		dLat := 0.01745329251994329577 * (pair.x1 - pair.x0)
		dLon := 0.01745329251994329577 * (pair.y1 - pair.y0)
		lat1 := 0.01745329251994329577 * pair.x0
		lat2 := 0.01745329251994329577 * pair.x1

		s0 := sine(dLat / 2)
		s1 := sine(dLon / 2)

		a := s0 * s0 + sine(lat1 + Half_PI) * sine(lat2 + Half_PI) * s1 * s1
		sqrt_a := sqrt(a)

		needs_transform := sqrt_a > Max_ArcSine
		asine_input := needs_transform ? sqrt(1.0 - sqrt_a * sqrt_a) : sqrt_a
		core := minimax_arcsine_unrolled(asine_input)
		asine_out := needs_transform ? Half_PI - core : core

		sum += 2.0 * asine_out * earth_radius
	}
	return sum / f64(len(pairs))
}

simplified_haversine_v1 :: proc(pairs: []generator.Pair) -> f64 {
	// NOTE: simplifies asine_input transform

	sum: f64
	for pair in pairs {
		dLat := 0.01745329251994329577 * (pair.x1 - pair.x0)
		dLon := 0.01745329251994329577 * (pair.y1 - pair.y0)
		lat1 := 0.01745329251994329577 * pair.x0
		lat2 := 0.01745329251994329577 * pair.x1

		s0 := sine(dLat / 2)
		s1 := sine(dLon / 2)

		a := s0 * s0 + sine(lat1 + Half_PI) * sine(lat2 + Half_PI) * s1 * s1
		needs_transform := a > Max_ArcSine_Squared

		asine_input := needs_transform ? sqrt(1.0 - a) : sqrt(a)
		core := minimax_arcsine_unrolled(asine_input)
		asine_out := needs_transform ? Half_PI - core : core

		sum += 2.0 * asine_out * earth_radius
	}

	return sum / f64(len(pairs))
}

simplified_haversine_v2 :: proc(pairs: []generator.Pair) -> f64 {
	// NOTE: uses an fma and sum coefficient for the sum
	sum: f64
	sum_coefficient := (2.0 * earth_radius) / f64(len(pairs))
	for pair in pairs {
		dLat := 0.01745329251994329577 * (pair.x1 - pair.x0)
		dLon := 0.01745329251994329577 * (pair.y1 - pair.y0)
		lat1 := 0.01745329251994329577 * pair.x0
		lat2 := 0.01745329251994329577 * pair.x1

		s0 := sine(dLat / 2)
		s1 := sine(dLon / 2)

		a := s0 * s0 + sine(lat1 + Half_PI) * sine(lat2 + Half_PI) * s1 * s1
		needs_transform := a > Max_ArcSine_Squared

		asine_input := needs_transform ? sqrt(1.0 - a) : sqrt(a)
		core := minimax_arcsine_unrolled(asine_input)
		asine_out := needs_transform ? Half_PI - core : core

		sum = math.fmuladd(asine_out, sum_coefficient, sum)
	}
	return sum
}

simplified_haversine_v3 :: proc(pairs: []generator.Pair) -> f64 {
	// NOTE: uses an fma for the lat cosines
	sum: f64
	sum_coefficient := Double_Earth_Radius / f64(len(pairs))
	for pair in pairs {
		dLat := 0.01745329251994329577 * (pair.x1 - pair.x0)
		dLon := 0.01745329251994329577 * (pair.y1 - pair.y0)
		shifted_lat1 := math.fmuladd(0.01745329251994329577, pair.x0, Half_PI)
		shifted_lat2 := math.fmuladd(0.01745329251994329577, pair.x1, Half_PI)

		s0 := sine(dLat / 2)
		s1 := sine(dLon / 2)

		a := math.fmuladd(s0, s0, sine(shifted_lat1) * sine(shifted_lat2) * s1 * s1)
		needs_transform := a > Max_ArcSine_Squared

		asine_input := needs_transform ? sqrt(1.0 - a) : sqrt(a)
		core := minimax_arcsine_unrolled(asine_input)
		asine_out := needs_transform ? Half_PI - core : core

		sum = math.fmuladd(asine_out, sum_coefficient, sum)
	}
	return sum
}

simplified_haversine_v4 :: proc(pairs: []generator.Pair) -> f64 {
	// NOTE: takes out some unnecessary sine input conditioning
	sum: f64
	sum_coefficient := Double_Earth_Radius / f64(len(pairs))
	for pair in pairs {
		dLat := 0.01745329251994329577 * (pair.x1 - pair.x0)
		dLon := 0.01745329251994329577 * (pair.y1 - pair.y0)
		shifted_lat1 := math.fmuladd(0.01745329251994329577, pair.x0, Half_PI)
		shifted_lat2 := math.fmuladd(0.01745329251994329577, pair.x1, Half_PI)

		s0_input := dLat / 2
		s1_input := dLon / 2

		// s0 := sine(dLat / 2)
		pos_s0 := math.abs(s0_input)
		quarter_s0 := pos_s0 > Half_PI ? math.PI - pos_s0 : pos_s0
		s0 := minimax_sine_unrolled(quarter_s0)

		// s1 := sine(dLon / 2)
		pos_s1 := math.abs(s1_input)
		quarter_s1 := pos_s1 > Half_PI ? math.PI - pos_s1 : pos_s1
		s1 := minimax_sine_unrolled(quarter_s1)

		// c0 := sine(shifted_lat1)
		quarter_x_c0 := shifted_lat1 > Half_PI ? math.PI - shifted_lat1 : shifted_lat1
		c0 := minimax_sine_unrolled(quarter_x_c0)

		// c1 := sine(shifted_lat2)
		quarter_x_c1 := shifted_lat2 > Half_PI ? math.PI - shifted_lat2 : shifted_lat2
		c1 := minimax_sine_unrolled(quarter_x_c1)

		a := math.fmuladd(s0, s0, c0 * c1 * s1 * s1)
		needs_transform := a > Max_ArcSine_Squared

		asine_input := needs_transform ? sqrt(1.0 - a) : sqrt(a)
		core := minimax_arcsine_unrolled(asine_input)
		asine_out := needs_transform ? Half_PI - core : core

		sum = math.fmuladd(asine_out, sum_coefficient, sum)
	}
	return sum
}

simplified_haversine_v5 :: proc(pairs: []generator.Pair) -> f64 {
	// NOTE: new asine unrolled from squared to avoid a squaring of a square root
	sum: f64
	sum_coefficient := Double_Earth_Radius / f64(len(pairs))
	for pair in pairs {
		dLat := 0.01745329251994329577 * (pair.x1 - pair.x0)
		dLon := 0.01745329251994329577 * (pair.y1 - pair.y0)
		shifted_lat1 := math.fmuladd(0.01745329251994329577, pair.x0, Half_PI)
		shifted_lat2 := math.fmuladd(0.01745329251994329577, pair.x1, Half_PI)

		s0_input := dLat / 2
		s1_input := dLon / 2

		// s0 := sine(dLat / 2)
		pos_s0 := math.abs(s0_input)
		quarter_s0 := pos_s0 > Half_PI ? math.PI - pos_s0 : pos_s0
		s0 := minimax_sine_unrolled(quarter_s0)

		// s1 := sine(dLon / 2)
		pos_s1 := math.abs(s1_input)
		quarter_s1 := pos_s1 > Half_PI ? math.PI - pos_s1 : pos_s1
		s1 := minimax_sine_unrolled(quarter_s1)

		// c0 := sine(shifted_lat1)
		quarter_x_c0 := shifted_lat1 > Half_PI ? math.PI - shifted_lat1 : shifted_lat1
		c0 := minimax_sine_unrolled(quarter_x_c0)

		// c1 := sine(shifted_lat2)
		quarter_x_c1 := shifted_lat2 > Half_PI ? math.PI - shifted_lat2 : shifted_lat2
		c1 := minimax_sine_unrolled(quarter_x_c1)

		a := math.fmuladd(s0, s0, c0 * c1 * s1 * s1)
		needs_transform := a > Max_ArcSine_Squared

		asine_input := needs_transform ? 1.0 - a : a
		core := minimax_arcsine_unrolled_from_squared(asine_input)
		asine_out := needs_transform ? Half_PI - core : core

		sum = math.fmuladd(asine_out, sum_coefficient, sum)
	}
	return sum
}

simplified_haversine_v6 :: proc(pairs: []generator.Pair) -> f64 {
	// NOTE: not sure how this math works, but its a further input simplifier
	sum: f64
	sum_coefficient := Double_Earth_Radius / f64(len(pairs))
	for pair in pairs {
		lat_coefficient_1 := pair.x0 < 0 ? Rad_converter : -Rad_converter
		lat_coefficient_2 := pair.x1 < 0 ? Rad_converter : -Rad_converter

		half_dLat := Half_rad_converter * (pair.x1 - pair.x0)
		half_dLon := Half_rad_converter * (pair.y1 - pair.y0)
		shifted_lat1 := math.fmuladd(lat_coefficient_1, pair.x0, Half_PI)
		shifted_lat2 := math.fmuladd(lat_coefficient_2, pair.x1, Half_PI)

		// s0 := sine(dLat / 2)
		pos_s0 := math.abs(half_dLat)
		quarter_s0 := pos_s0 > Half_PI ? math.PI - pos_s0 : pos_s0
		s0 := minimax_sine_unrolled(quarter_s0)

		// s1 := sine(dLon / 2)
		pos_s1 := math.abs(half_dLon)
		quarter_s1 := pos_s1 > Half_PI ? math.PI - pos_s1 : pos_s1
		s1 := minimax_sine_unrolled(quarter_s1)

		// c0 := sine(shifted_lat1)
		c0 := minimax_sine_unrolled(shifted_lat1)

		// c1 := sine(shifted_lat2)
		c1 := minimax_sine_unrolled(shifted_lat2)

		a := math.fmuladd(s0, s0, c0 * c1 * s1 * s1)
		needs_transform := a > Max_ArcSine_Squared

		asine_input := needs_transform ? 1.0 - a : a
		core := minimax_arcsine_unrolled_from_squared(asine_input)
		asine_out := needs_transform ? Half_PI - core : core

		sum = math.fmuladd(asine_out, sum_coefficient, sum)
	}
	return sum
}
