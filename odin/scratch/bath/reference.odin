package bath

square :: proc(a: f64) -> f64 {
	result := a * a
	return result
}

radians_from_degrees :: proc(degrees: f64) -> f64 {
	result := 0.01745329251994329577 * degrees
	return result
}

earth_radius :: 6372.8

haversine :: proc(t: ^domain_tracker, x0, y0, x1, y1: f64) -> f64 {
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

	print(t)

	result := earth_radius * c

	return result
}
