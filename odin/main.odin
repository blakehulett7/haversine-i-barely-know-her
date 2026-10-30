package main

import "core:flags"
import "core:fmt"
import "core:os"
import "generator"
import "metrics"
import "perform"

Config :: struct {
	generate: bool `args:"name=g" usage:"pass true to generate new input file"`,
	num:      u64 `args:"name=n" usage:"enter number of pairs to generate"`,
	seed:     u64 `args:"name=s" usage:"enter a random seed"`,
	data:     string `args:"name=d" usage:"enter the path to the input json file"`,
}

main :: proc() {
	fmt.println("Pax Vobiscum")

	metrics.os_time_test()
	return

	/*
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

	perform_err := perform.work(path)
	if perform_err != nil {
		fmt.printfln("error: %v", perform_err)
		os.exit(1)
	}
    */
}
