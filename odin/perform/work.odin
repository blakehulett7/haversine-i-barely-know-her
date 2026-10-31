package perform

import "../bson"
import "../calc"
import "../generator"
import "../metrics"
import "core:fmt"
import "core:os"
import "core:slice"

work :: proc(path: string) -> Error {
	start := metrics.read_cpu_timer()


	parsed: generator.Out
	data := os.read_entire_file("data/pairs.json", context.allocator) or_return

	parse_start := metrics.read_cpu_timer()
	bson.parse(&parsed, data) or_return

	calc_start := metrics.read_cpu_timer()
	haversine_sum: f64
	answers := make([]f64, len(parsed.pairs))

	for pair, i in parsed.pairs {
		haversine := calc.reference_haversine(pair.x0, pair.y0, pair.x1, pair.y1)
		haversine_sum += haversine
		answers[i] = haversine
	}
	avg_haversine := haversine_sum / f64(len(answers))

	write_start := metrics.read_cpu_timer()
	os.write_entire_file("data/computed.f64", slice.to_bytes(answers)) or_return
	write_end := metrics.read_cpu_timer()

	fmt.printfln("expected avg: %f", parsed.answer)
	fmt.printfln("got avg: %f", avg_haversine)
	fmt.printfln("success: %t", avg_haversine == parsed.answer)

	end := metrics.read_cpu_timer()
	elapsed := end - start
	fmt.printfln("\nTotal ticks: %d", elapsed)

	cpu_freq := metrics.read_cpu_frequency()
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
