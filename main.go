package main

import (
	"encoding/binary"
	"fmt"
	"haversine-i-barely-know-her/json"
	"haversine-i-barely-know-her/metrics"
	"os"
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
	metrics_done := metrics.NewMetrics()
	defer func() {
		close(metrics.MetricsChan)
		<-metrics_done
	}()

	data, err := os.ReadFile("./points_1000000.json")
	if err != nil {
		fmt.Println("could not open json file")
		os.Exit(1)
	}

	var input Data
	err = json.Parse(&input, data)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var rolling_sum float64
	answers := []float64{}

	rolling_sum = RecursiveHaversine(input.Pairs, 0)

	// for _, pair := range input.Pairs {
	// 	haversine := ReferenceHaversine(pair)
	// 	answers = append(answers, haversine)
	// 	rolling_sum += haversine
	//    }

	avg := rolling_sum / float64(len(input.Pairs))

	path := "out.f64"
	file, err := os.Create(path)
	if err != nil {
		fmt.Println("could not create answer file")
		os.Exit(1)
	}
	defer file.Close()

	err = binary.Write(file, binary.LittleEndian, answers)
	if err != nil {
		fmt.Println("could not save answer file")
		os.Exit(1)
	}

	fmt.Printf("got avg: %f\n", avg)
	fmt.Println()
}
