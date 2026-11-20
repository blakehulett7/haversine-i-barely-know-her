package main

import "../../bson"
import "../../generator"
import "../../scratch/bath"
import "core:os"
import "core:slice"

main :: proc() {
	run()
}

run :: proc() -> Error {
	parsed: generator.Out
	data: []byte
	anchor_idx: int

	data = os.read_entire_file("../../data/pairs.json", context.allocator) or_return

	bson.parse(&parsed, data) or_return

	answers := make([]f64, len(parsed.pairs), context.temp_allocator)
	avg_haversine: f64

	t: bath.domain_tracker

	for {
		haversine_sum: f64
		for pair, i in parsed.pairs {
			haversine := bath.haversine(&t, pair.x0, pair.y0, pair.x1, pair.y1)
			haversine_sum += haversine
			answers[i] = haversine
		}
		avg_haversine = haversine_sum / f64(len(answers))
	}


	os.write_entire_file("data/computed.f64", slice.to_bytes(answers)) or_return


	return nil
}
