package main

const count = 1024

func main() {
	data := make([]byte, count)
	write_to_buffer(data, count)
}

func write_all(dest *buffer) {
	for i := range dest.count {
		dest.data[i] = byte(i)
	}
}

func write_small(count int) {
	data := make([]byte, count)
	for i := range count {
		data[i] = byte(i)
	}
}

func write_to_buffer(buffer []byte, count int) {
	for i := range count {
		buffer[i] = byte(i)
	}
}

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
