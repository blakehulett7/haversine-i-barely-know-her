package json

import (
	"fmt"
	"haversine-i-barely-know-her/metrics"
	"haversine-i-barely-know-her/models"
	"os"
	"strconv"
)

const row_size = 4

func QuickParse(data []byte, size int) []models.Row {
	start := metrics.Start(metrics.QuickParse)
	defer metrics.End(start, uint64(len(data)), metrics.QuickParse)

	rows := make([]models.Row, size)

	s := string(data)
	runes := []rune(s)
	cursor := find_next(runes, 0, ':')
	cursor++

	for idx := range size {
		rows[idx], cursor = parse_row(runes, cursor)
	}

	return rows
}

func find_next(runes []rune, cursor int, target rune) int {
	for {
		if runes[cursor] == target {
			return cursor
		}
		cursor++
	}
}

func parse_row(runes []rune, cursor int) (models.Row, int) {
	var floats [4]float64
	var end int

	for idx := range row_size {
		cursor = find_next(runes, cursor, ':')
		cursor++

		if idx == 3 {
			end = find_next(runes, cursor, '\n')
		} else {
			end = find_next(runes, cursor, ',')
		}

		f, err := strconv.ParseFloat(string(runes[cursor+1:end]), 64)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		floats[idx] = f
	}

	return models.Row{
		X0: floats[0],
		Y0: floats[1],
		X1: floats[2],
		Y1: floats[3],
	}, cursor
}
