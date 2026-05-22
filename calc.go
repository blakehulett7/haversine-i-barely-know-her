package main

import (
	"haversine-i-barely-know-her/metrics"
	"math"
)

func ReferenceHaversine(pair Row) float64 {
	start := metrics.Start(metrics.ReferenceHaversine)
	defer metrics.End(start, metrics.ReferenceHaversine)

	lat1 := pair.Y0
	lat2 := pair.Y1
	lon1 := pair.X0
	lon2 := pair.X1

	dLat := radiansFromDegrees(lat2 - lat1)
	dLon := radiansFromDegrees(lon2 - lon1)
	lat1 = radiansFromDegrees(lat1)
	lat2 = radiansFromDegrees(lat2)

	a := square(math.Sin(dLat/2.0)) + math.Cos(lat1)*math.Cos(lat2)*square(math.Sin(dLon/2))
	c := 2.0 * math.Asin(math.Sqrt(a))

	result := EarthRadius * c

	return result
}

func radiansFromDegrees(degrees float64) float64 {
	return 0.01745329251994329577 * degrees
}

func square(a float64) float64 {
	return a * a
}
