package perform

import "../bath"
import "../bson"
import "../calc"
import "../generator"
import "core:fmt"
import "core:os"

test :: proc(path: string) -> Error {
	parsed: generator.Out
	data: []byte
	anchor_idx: int
	data = os.read_entire_file(path, context.allocator) or_return

	bson.parse(&parsed, data) or_return

	reference_haversine_sum: f64
	bath_haversine_sum: f64

	for pair, i in parsed.pairs {
		reference_haversine := calc.reference_haversine(pair.x0, pair.y0, pair.x1, pair.y1)
		bath_haversine := bath.haversine(pair.x0, pair.y0, pair.x1, pair.y1)

		reference_haversine_sum += reference_haversine
		bath_haversine_sum += bath_haversine
	}

	avg_reference_haversine := reference_haversine_sum / f64(len(parsed.pairs))
	avg_bath_haversine := bath_haversine_sum / f64(len(parsed.pairs))

	delta_reference := parsed.answer - avg_reference_haversine
	delta_bath := parsed.answer - avg_bath_haversine

	fmt.printfln("\nexpected avg: %.17f", parsed.answer)
	fmt.printfln("\n\treference avg: %.17f", avg_reference_haversine)
	fmt.printfln("\t\tdelta_expected : %+.17f", delta_reference)
	fmt.printfln("\t\tdelta_bath     : %+.17f", avg_bath_haversine - avg_reference_haversine)
	fmt.printfln("\n\tbath avg     : %.17f", avg_bath_haversine)
	fmt.printfln("\t\tdelta_expected : %+.17f", delta_bath)
	fmt.printfln("\t\tdelta_reference: %+.17f", avg_reference_haversine - avg_bath_haversine)
	fmt.println()

	return nil
}
