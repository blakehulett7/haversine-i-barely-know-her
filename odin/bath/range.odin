package bath

import "core:fmt"
import "core:math"

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

cos :: proc(t: ^domain_tracker, x: f64) -> f64 {
	domain := &t.cos
	track(domain, x)
	return math.cos(x)
}

sin :: proc(t: ^domain_tracker, x: f64) -> f64 {
	domain := &t.sin
	track(domain, x)
	return math.sin(x)
}

sqrt :: proc(t: ^domain_tracker, x: f64) -> f64 {
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
