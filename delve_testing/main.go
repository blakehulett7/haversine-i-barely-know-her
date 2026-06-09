package main

const count = 1024

func main() {
	data := make([]byte, count)
	dec_bytes(data, count)
}

func write_to_buffer(buffer []byte, count int) {
	for i := range count {
		buffer[i] = byte(i)
	}
}

//go:noescape
func mov_bytes(buffer []byte, count int)

//go:noescape
func mov_bytes_quick(buffer []byte, count int)

//go:noescape
func nop_bytes(buffer []byte, count int)

//go:noescape
func cmp_bytes(buffer []byte, count int)

//go:noescape
func dec_bytes(buffer []byte, count int)

func goPanicIndex() {
	panic("runtime error: index out of range")
}
