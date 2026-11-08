package main

import "core:fmt"
import "core:mem/virtual"
import "core:os"

test_func :: proc(t: ^tester, path: string, with_malloc: bool)

default :: proc(t: ^tester, path: string, with_malloc: bool) {
	arena: virtual.Arena
	allocator := context.allocator

	if with_malloc {
		err := virtual.arena_init_growing(&arena)
		if err != nil {
			fmt.println("could not init growing arena")
			return
		}
		allocator = virtual.arena_allocator(&arena)
	}

	defer virtual.arena_destroy(&arena)

	for is_testing(t) {
		begin_time(t)
		data, err := os.read_entire_file(path, allocator)
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

		if with_malloc {
			free_all(allocator)
		} else {
			delete(data)
		}
	}
}

write_all_bytes :: proc(t: ^tester, path: string, with_malloc: bool) {
	arena: virtual.Arena
	allocator := context.allocator

	if with_malloc {
		err := virtual.arena_init_growing(&arena)
		if err != nil {
			fmt.println("could not init growing arena")
			return
		}
		allocator = virtual.arena_allocator(&arena)
	}

	defer virtual.arena_destroy(&arena)

	f, err := os.open(path)
	if err != nil {
		return
	}

	size, s_err := os.file_size(f)
	if s_err != nil {
		return
	}

	t.target_processed_bytes = size

	for is_testing(t) {
		dest := make([]byte, size, allocator)

		begin_time(t)
		for i in 0 ..< size {
			dest[i] = byte(i)
		}
		end_time(t, u64(size))

		count_bytes(t, u64(size))

		if with_malloc {
			free_all(allocator)
		} else {
			delete(dest)
		}
	}
}

write_all_bytes_backward :: proc(t: ^tester, path: string, with_malloc: bool) {
	arena: virtual.Arena
	allocator := context.allocator

	if with_malloc {
		err := virtual.arena_init_growing(&arena)
		if err != nil {
			fmt.println("could not init growing arena")
			return
		}
		allocator = virtual.arena_allocator(&arena)
	}

	defer virtual.arena_destroy(&arena)

	f, err := os.open(path)
	if err != nil {
		return
	}

	size, s_err := os.file_size(f)
	if s_err != nil {
		return
	}

	for is_testing(t) {
		dest := make([]byte, size, allocator)

		begin_time(t)
		for i in 0 ..< size {
			dest[(len(dest) - 1) - int(i)] = byte(i)
		}
		end_time(t, u64(size))

		if t.target_processed_bytes == 0 {
			t.target_processed_bytes = size
			count_bytes(t, u64(size))
		}
		count_bytes(t, u64(size))

		if with_malloc {
			free_all(allocator)
		} else {
			delete(dest)
		}
	}
}
