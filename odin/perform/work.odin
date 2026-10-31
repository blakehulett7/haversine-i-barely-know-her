package perform

import "../bson"
import "../calc"
import "../generator"
import "../metrics"
import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:slice"

work :: proc(path: string) -> Error {
	start := intrinsics.read_cycle_counter()

	parsed: generator.Out
	data := os.read_entire_file("data/pairs.json", context.allocator) or_return

	parse_start := intrinsics.read_cycle_counter()
	bson.parse(&parsed, data) or_return

	calc_start := intrinsics.read_cycle_counter()
	haversine_sum: f64
	answers := make([]f64, len(parsed.pairs))

	for pair, i in parsed.pairs {
		haversine := calc.reference_haversine(pair.x0, pair.y0, pair.x1, pair.y1)
		haversine_sum += haversine
		answers[i] = haversine
	}
	avg_haversine := haversine_sum / f64(len(answers))

	write_start := intrinsics.read_cycle_counter()
	os.write_entire_file("data/computed.f64", slice.to_bytes(answers)) or_return
	write_end := intrinsics.read_cycle_counter()

	delete(answers)

	fmt.printfln("expected avg: %f", parsed.answer)
	fmt.printfln("got avg: %f", avg_haversine)
	fmt.printfln("success: %t", avg_haversine == parsed.answer)

	end := intrinsics.read_cycle_counter()
	elapsed := end - start
	fmt.printfln("\nTotal ticks: %d", elapsed)

	cpu_freq := intrinsics.read_cycle_counter_frequency()
	fmt.printf(
		"Total time: %0.4fms (CPU freq %d)\n",
		1000.0 * f64(elapsed) / f64(cpu_freq),
		cpu_freq,
	)

	metrics.print_time_elapsed("read", elapsed, start, parse_start)
	metrics.print_time_elapsed("parse", elapsed, parse_start, calc_start)
	metrics.print_time_elapsed("calc", elapsed, calc_start, write_start)
	metrics.print_time_elapsed("write", elapsed, write_start, write_end)
	metrics.print_time_elapsed("printout", elapsed, write_end, end)

	return nil
}
