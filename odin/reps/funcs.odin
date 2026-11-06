package main

import "core:fmt"
import "core:mem/virtual"
import "core:os"

read_func :: proc(t: ^tester, path: string)

default :: proc(t: ^tester, path: string) {
	for is_testing(t) {
		begin_time(t)
		data, err := os.read_entire_file(path, context.allocator)
		end_time(t, u64(len(data)))

		if t.target_processed_bytes == 0 {
			t.target_processed_bytes = i64(len(data))
			count_bytes(t, u64(len(data)))
		}

		defer delete(data)

		if err != nil {
			t.mode = .errored
			continue
		}
		count_bytes(t, u64(len(data)))
	}
}

with_malloc :: proc(t: ^tester, path: string) {
	mb := 1024 * 1024

	arena: virtual.Arena
	err := virtual.arena_init_growing(&arena)
	if err != nil {
		fmt.println("could not init growing arena")
		return
	}
	defer virtual.arena_destroy(&arena)


	for is_testing(t) {
		begin_time(t)
		data, err := os.read_entire_file(path, virtual.arena_allocator(&arena))
		end_time(t, u64(len(data)))

		if t.target_processed_bytes == 0 {
			t.target_processed_bytes = i64(len(data))
			count_bytes(t, u64(len(data)))
		}

		if err != nil {
			t.mode = .errored
			continue
		}
		count_bytes(t, u64(len(data)))

		free_all(virtual.arena_allocator(&arena))
	}
}
