package json

import (
	"haversine-i-barely-know-her/models"
)

type chunk struct {
	idx  int
	rows []models.Row
}

func parse_parallel(size int) (chan chunk, chan []models.Row) {
	collector := make(chan chunk)
	done := make(chan []models.Row)

	go func() {
		var chunks [threads][]models.Row
		remaining_chunks := threads

		for remaining_chunks > 0 {
			chunk := <-collector
			chunks[chunk.idx] = chunk.rows
			remaining_chunks--
		}

		rows := make([]models.Row, 0, size)
		for _, chunk := range chunks {
			rows = append(rows, chunk...)
		}

		done <- rows
	}()

	return collector, done
}

func parse_chunk(collector chan chunk, runes []rune, idx int) {
	cursor := 22

	var rows []models.Row
	for has_colon(runes, cursor) {
		var row models.Row
		row, cursor = parse_row(runes, cursor)
		rows = append(rows, row)
	}

	collector <- chunk{
		idx:  idx,
		rows: rows,
	}
}
