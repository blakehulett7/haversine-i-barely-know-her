package main

import "bson"
import "core:flags"
import "core:fmt"
import "core:os"
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

	data, readErr := os.read_entire_file("data/pairs.json", context.allocator)
	if readErr != nil {
		fmt.println("could not read json file")
		os.exit(1)
	}

	err := bson.parse(&parsed, data)
	if err != nil {
		fmt.printfln("error: %v\n", err)
		return
	}

	fmt.println(parsed)
}
