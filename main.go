package main

import (
	"encoding/binary"
	"fmt"
	"haversine-i-barely-know-her/json"
	"os"
	"time"
)

type Data struct {
	Pairs []Row `json:"pairs"`
}

type Row struct {
	X0 float64 `json:"x0"`
	Y0 float64 `json:"y0"`
	X1 float64 `json:"x1"`
	Y1 float64 `json:"y1"`
}

const EarthRadius = 6372.8

func main() {
	start := time.Now()

	startup_time := time.Now()
	data, err := os.ReadFile("./points_5000000.json")
	if err != nil {
		fmt.Println("could not open json file")
		os.Exit(1)
	}

	read_time := time.Now()

	var input Data
	err = json.Parse(&input, data)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	parse_time := time.Now()

	var rolling_sum float64
	answers := []float64{}
	for _, pair := range input.Pairs {
		haversine := ReferenceHaversine(pair)
		answers = append(answers, haversine)
		rolling_sum += haversine
	}

	avg := rolling_sum / float64(len(input.Pairs))

	calc_time := time.Now()

	path := "out.f64"
	file, err := os.Create(path)
	if err != nil {
		fmt.Println("could not create answer file")
		os.Exit(1)
	}
	defer file.Close()

	create_file_time := time.Now()

	err = binary.Write(file, binary.LittleEndian, answers)
	if err != nil {
		fmt.Println("could not save answer file")
		os.Exit(1)
	}

	write_time := time.Now()

	fmt.Printf("got avg: %f\n", avg)

	end := time.Now()

	fmt.Println()

	total_duration := end.Sub(start).Milliseconds()
	startup_duration := startup_time.Sub(start).Milliseconds()
	read_duration := read_time.Sub(startup_time).Milliseconds()
	parse_duration := parse_time.Sub(read_time).Milliseconds()
	calc_duration := calc_time.Sub(parse_time).Milliseconds()
	create_file_duration := create_file_time.Sub(calc_time).Milliseconds()
	write_duration := write_time.Sub(create_file_time).Milliseconds()
	cleanup_duration := end.Sub(write_time).Milliseconds()

	fmt.Printf("Total Time: %d\n", total_duration)
	fmt.Printf("\tStartup Time: %d (%.2f%%)\n", startup_duration, asPercent(startup_duration, total_duration))
	fmt.Printf("\tRead Time: %d (%.2f%%)\n", read_duration, asPercent(read_duration, total_duration))
	fmt.Printf("\tParse Time: %d (%.2f%%)\n", parse_duration, asPercent(parse_duration, total_duration))
	fmt.Printf("\tCalc Time: %d (%.2f%%)\n", calc_duration, asPercent(calc_duration, total_duration))
	fmt.Printf("\tCreate Time: %d (%.2f%%)\n", create_file_duration, asPercent(create_file_duration, total_duration))
	fmt.Printf("\tWrite Time: %d (%.2f%%)\n", write_duration, asPercent(write_duration, total_duration))
	fmt.Printf("\tCleanup Time: %d (%.2f%%)\n", cleanup_duration, asPercent(cleanup_duration, total_duration))
}

func asPercent(num, den int64) f64 {
	return (f64(num) / f64(den)) * 100
}
