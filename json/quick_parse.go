package json

import (
	"fmt"
	"haversine-i-barely-know-her/models"
)

var intro = []rune("{\n   \"pairs\": [")

func QuickParse(data []byte, size int) []models.Row {
	// rows := make([]models.Row, size)
	// idx := 0

	s := string(data)
	runes := []rune(s)

	entry := 0
	exit := 0

	for {
		if runes[exit] == '[' {
			exit++
			break
		}
		exit++
	}

	fmt.Println(runes[entry:exit])
	fmt.Println(intro)
	fmt.Println(runes[entry:exit] == intro)
	return nil
}
