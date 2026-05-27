package main

import (
	"encoding/binary"
	"fmt"
	"haversine-i-barely-know-her/json"
	"haversine-i-barely-know-her/metrics"
	"haversine-i-barely-know-her/models"
	"os"
	"unsafe"
)

type Data struct {
	Pairs []models.Row `json:"pairs"`
}

type Row struct {
	X0 float64 `json:"x0"`
	Y0 float64 `json:"y0"`
	X1 float64 `json:"x1"`
	Y1 float64 `json:"y1"`
}

const EarthRadius = 6372.8

func main() {
	metrics_done := metrics.NewMetrics(false)
	defer func() {
		close(metrics.MetricsChan)
		<-metrics_done
	}()

	fmt.Println()

	start := metrics.Start(metrics.ReadFile)
	data, err := os.ReadFile("./points_1000000.json")
	metrics.End(start, uint64(len(data)), metrics.ReadFile)
	if err != nil {
		fmt.Println("could not open json file")
		os.Exit(1)
	}

	var input Data
	input.Pairs = json.QuickParse(data, 1000000)
	// err = json.Parse(&input, data)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var rolling_sum float64
	answers := []float64{}

	// rolling_sum = RecursiveHaversine(input.Pairs, 0)

	sizeof_pairs := uintptr(len(input.Pairs)) * unsafe.Sizeof(Row{})

	start = metrics.Start(metrics.ReferenceHaversine)
	for _, pair := range input.Pairs {
		haversine := ReferenceHaversine(pair)
		answers = append(answers, haversine)
		rolling_sum += haversine
	}
	metrics.End(start, uint64(sizeof_pairs), metrics.ReferenceHaversine)

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
