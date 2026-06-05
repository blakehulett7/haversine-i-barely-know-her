package main

const count = 1024

func main() {
	data := make([]byte, count)
	mov_bytes(data, count)
}

func write_to_buffer(buffer []byte, count int) {
	for i := range count {
		buffer[i] = byte(i)
	}
}

//go:noescape
func mov_bytes(buffer []byte, count int)
