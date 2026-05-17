package main

import (
	"fmt"
	"haversine-i-barely-know-her/json"
	"os"
)

func main() {
	data, err := os.ReadFile("./points_10.json")
	if err != nil {
		fmt.Println("could not open json file")
		os.Exit(1)
	}

	dest := map[string]string{}

	err = json.Parse(&dest, data)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
