package main

func mov_all(count int) int {
	data := make([]byte, count)
	mov_bytes(data, count)
	return count
}

func mov_quick(count int) int {
	data := make([]byte, count)
	mov_bytes_quick(data, count)
	return count
}

func nop_all(count int) int {
	data := make([]byte, count)
	nop_bytes(data, count)
	return count
}

func cmp_all(count int) int {
	data := make([]byte, count)
	cmp_bytes(data, count)
	return count
}

func dec_all(count int) int {
	data := make([]byte, count)
	dec_bytes(data, count)
	return count
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

func write_all(count int) int {
	data := make([]byte, count)
	for i := range count {
		data[i] = byte(i)
	}
	return count
}
