package main

import (
	"fmt"
	"haversine-i-barely-know-her/json"
	"os"
)

type Data struct {
	pairs []Row `json:"pairs"`
}

type Row struct {
	x0 float64 `json:"x0"`
	y0 float64 `json:"y0"`
	x1 float64 `json:"x1"`
	y1 float64 `json:"y1"`
}

const EarthRadius = 6372.8

func main() {
	data, err := os.ReadFile("./points_10.json")
	if err != nil {
		fmt.Println("could not open json file")
		os.Exit(1)
	}

	var dest Data

	err = json.Parse(&dest, data)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
