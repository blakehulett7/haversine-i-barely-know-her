package main

func write_all(count int) int {
	data := make([]byte, count)
	for i := range count {
		data[i] = byte(i)
	}
	return count
}
