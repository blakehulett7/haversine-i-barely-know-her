package perform

import "../bson"
import "../calc"
import "../generator"
import "../metrics"
import "core:fmt"
import "core:os"
import "core:slice"

work :: proc(path: string) -> Error {
	metrics.begin_profiler()

	parsed: generator.Out
	data: []byte
	{
		metrics.profile("read")
		data = os.read_entire_file("data/pairs.json", context.allocator) or_return
	}

	{
		metrics.profile("parse")
		bson.parse(&parsed, data) or_return
	}

	answers := make([]f64, len(parsed.pairs))
	avg_haversine: f64

	{
		metrics.profile("calc")
		haversine_sum: f64

		for pair, i in parsed.pairs {
			haversine := calc.reference_haversine(pair.x0, pair.y0, pair.x1, pair.y1)
			haversine_sum += haversine
			answers[i] = haversine
		}
		avg_haversine = haversine_sum / f64(len(answers))
	}

	{
		metrics.profile("write")
		os.write_entire_file("data/computed.f64", slice.to_bytes(answers)) or_return
	}

	delete(answers)

	fmt.printfln("expected avg: %f", parsed.answer)
	fmt.printfln("got avg: %f", avg_haversine)
	fmt.printfln("success: %t", avg_haversine == parsed.answer)

	return nil
}
