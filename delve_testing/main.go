package main

type buffer struct {
	data  []byte
	count int
}

func new_buffer(count int) buffer {
	return buffer{
		data:  make([]byte, count),
		count: count,
	}
}

func main() {
	buffer := new_buffer(1024)
	write_all(&buffer)
}

func write_all(dest *buffer) {
	for i := range dest.count {
		dest.data[i] = byte(i)
	}
}
