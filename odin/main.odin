package main

import "bson"
import "calc"
import "core:flags"
import "core:fmt"
import "core:os"
import "core:slice"
import "generator"

Config :: struct {
	generate: bool `args:"name=g" usage:"pass true to generate new input file"`,
	num:      u64 `args:"name=n" usage:"enter number of pairs to generate"`,
	seed:     u64 `args:"name=s" usage:"enter a random seed"`,
	data:     string `args:"name=d" usage:"enter the path to the input json file"`,
}

main :: proc() {
	fmt.println("Pax Vobiscum")

	config: Config
	flags.parse_or_exit(&config, os.args)

	if config.generate && config.num == 0 {
		fmt.println("invalid config, must pass num if in generate mode")
		os.exit(1)
	}

	if config.generate {
		err := generator.input(config.seed, config.num)
		if err != nil {
			fmt.printfln("error generating input json: %v", err)
			os.exit(1)
		}
		os.exit(0)
	}

	path := config.data
	if path == "" {
		fmt.println("using default data path")
		path = "data/pairs.json"
	}

	parsed: generator.Out
	data, read_err := os.read_entire_file("data/pairs.json", context.allocator)
	if read_err != nil {
		fmt.println("could not read json file")
		os.exit(1)
	}

	err := bson.parse(&parsed, data)
	if err != nil {
		fmt.printfln("error: %v\n", err)
		return
	}

	haversine_sum: f64
	answers := make([]f64, len(parsed.pairs))

	for pair, i in parsed.pairs {
		haversine := calc.reference_haversine(pair.x0, pair.y0, pair.x1, pair.y1)
		haversine_sum += haversine
		answers[i] = haversine
	}

	_ = os.write_entire_file("data/computed.f64", slice.to_bytes(answers))
	avg_haversine := haversine_sum / f64(len(answers))

	fmt.printfln("expected avg: %f", parsed.answer)
	fmt.printfln("got avg: %f", avg_haversine)
	fmt.printfln("success: %t", avg_haversine == parsed.answer)
}
