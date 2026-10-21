package main

import "bson"
import "core:flags"
import "core:fmt"
import "core:os"
import "core:slice"
import "generator"

Config :: struct {
	num:  u64 `args:"name=n,required" usage:"enter number of pairs to generate"`,
	seed: u64 `args:"name=s" usage:"enter a random seed"`,
}

main :: proc() {
	fmt.println("Pax Vobiscum")

	config: Config
	flags.parse_or_exit(&config, os.args)
	out := generator.input(config.seed, config.num)

	haversine_sum: f64
	answers := make([]f64, config.num)

	for pair, i in out.pairs {
		haversine := reference_haversine(pair.x0, pair.y0, pair.x1, pair.y1)
		haversine_sum += haversine
		answers[i] = haversine
	}

	avg_haversine := haversine_sum / f64(len(out.pairs))
	fmt.println(avg_haversine)

	_ = os.write_entire_file("data/answers.f64", slice.to_bytes(answers))

	// bson.parse(&out, []byte{})
}
