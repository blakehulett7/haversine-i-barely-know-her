package main

import "core:fmt"
import "core:os"

read_func :: proc(t: ^tester, path: string)

default :: proc(t: ^tester, path: string) {
	for is_testing(t) {
		begin_time(t)
		data, err := os.read_entire_file(path, context.allocator)
		end_time(t, i64(len(data)))

		if t.target_processed_bytes == 0 {
			t.target_processed_bytes = i64(len(data))
			count_bytes(t, i64(len(data)))
		}

		defer delete(data)

		if err != nil {
			t.mode = .errored
			continue
		}
		count_bytes(t, i64(len(data)))
	}
}
