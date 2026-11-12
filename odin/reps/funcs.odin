package main

import "core:fmt"
import "core:math"
import "core:mem/virtual"
import "core:os"

foreign import lib {"../asm/lib/front_end_test.a", "../asm/lib/nop_test.a", "../asm/lib/conditional_nop_test.a", "../asm/lib/alignment_test.a", "../asm/lib/rat_test.a", "../asm/lib/ports_test.a", "../asm/lib/simd_test.a", "../asm/lib/cache_test.a"}

foreign lib {
	MOVAllBytesASM :: proc(dest: ^byte, count: uint) ---
	NOPAllBytesASM :: proc(dest: ^byte, count: uint) ---
	CMPAllBytesASM :: proc(dest: ^byte, count: uint) ---
	DECAllBytesASM :: proc(dest: ^byte, count: uint) ---

	NOP4x1AllBytesASM :: proc(dest: ^byte, count: uint) ---
	NOP4x3AllBytesASM :: proc(dest: ^byte, count: uint) ---
	NOP4x9AllBytesASM :: proc(dest: ^byte, count: uint) ---
	NOPx1AllBytesASM :: proc(dest: ^byte, count: uint) ---
	NOPx3AllBytesASM :: proc(dest: ^byte, count: uint) ---
	NOPx9AllBytesASM :: proc(dest: ^byte, count: uint) ---
	NOPx18AllBytesASM :: proc(dest: ^byte, count: uint) ---

	ConditionalNOP :: proc(dest: ^byte, count: uint) ---

	NOPAligned64 :: proc(count: uint) ---
	NOPAligned4 :: proc(count: uint) ---
	NOPAligned16 :: proc(count: uint) ---
	NOPAligned32 :: proc(count: uint) ---
	NOPAligned60 :: proc(count: uint) ---

	RATAdd :: proc(count: uint) ---
	RATMovAdd :: proc(count: uint) ---

	Read_x1 :: proc(dest: ^byte, count: uint) ---
	Read_x2 :: proc(dest: ^byte, count: uint) ---
	Read_x3 :: proc(dest: ^byte, count: uint) ---
	Read_x4 :: proc(dest: ^byte, count: uint) ---
	Write_x1 :: proc(dest: ^byte, count: uint) ---
	Write_x2 :: proc(dest: ^byte, count: uint) ---
	Write_x3 :: proc(dest: ^byte, count: uint) ---
	Write_x4 :: proc(dest: ^byte, count: uint) ---

	Read_4x3 :: proc(dest: ^byte, count: uint) ---
	Read_8x3 :: proc(dest: ^byte, count: uint) ---
	Read_16x2 :: proc(dest: ^byte, count: uint) ---
	Read_16x3 :: proc(dest: ^byte, count: uint) ---
	Read_32x2 :: proc(dest: ^byte, count: uint) ---
	Read_32x3 :: proc(dest: ^byte, count: uint) ---
	Read_64x3 :: proc(dest: ^byte, count: uint) ---

	Cache_4K :: proc(dest: ^byte, count: uint) ---
	Cache_64K :: proc(dest: ^byte, count: uint) ---
	Cache_1M :: proc(dest: ^byte, count: uint) ---
	Cache_16M :: proc(dest: ^byte, count: uint) ---
	Cache_256M :: proc(dest: ^byte, count: uint) ---
	Cache_4G :: proc(dest: ^byte, count: uint) ---

	Cache :: proc(dest: ^byte, count, mask: uint) ---
}

alignment_test :: proc "cdecl" (count: uint)
asm_func :: proc "cdecl" (dest: ^byte, count: uint)
cache_func :: proc(t: ^tester, dest: []byte, mask: uint)
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

custom_asm :: proc(t: ^tester, path: string, func: asm_func) {
	size: i64 = 4 * 1024 * 1024 * 1024

	for is_testing(t) {
		dest := make([]byte, size)

		begin_time(t)
		func(raw_data(dest), uint(size))
		end_time(t, u64(size))

		if t.target_processed_bytes == 0 {
			t.target_processed_bytes = size
			count_bytes(t, u64(size))
		}
		count_bytes(t, u64(size))

		delete(dest)
	}
}

custom_cache :: proc(t: ^tester, dest: []byte, mask: uint) {
	count: u64 = 4 * 1024 * 1024 * 1024
	bits := 1 << mask

	for is_testing(t) {
		begin_time(t)
		Cache(raw_data(dest), uint(count), uint(bits))
		end_time(t, count)

		if t.target_processed_bytes == 0 {
			t.target_processed_bytes = i64(count)
			count_bytes(t, count)
		}
		count_bytes(t, count)
	}
}

custom_alignment_test :: proc(t: ^tester, path: string, func: alignment_test) {
	count: u64 = 1024 * 1024 * 1024

	for is_testing(t) {
		begin_time(t)
		func(uint(count))
		end_time(t, count)

		if t.target_processed_bytes == 0 {
			t.target_processed_bytes = i64(count)
			count_bytes(t, count)
		}
		count_bytes(t, count)
	}
}

mov_all_bytes :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, MOVAllBytesASM)
}

nop_all_bytes :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, NOPAllBytesASM)
}

cmp_all_bytes :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, CMPAllBytesASM)
}

dec_all_bytes :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, DECAllBytesASM)
}

nop_4x1 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, NOP4x1AllBytesASM)
}

nop_4x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, NOP4x3AllBytesASM)
}

nop_4x9 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, NOP4x9AllBytesASM)
}

nop_x1 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, NOPx1AllBytesASM)
}

nop_x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, NOPx3AllBytesASM)
}

nop_x9 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, NOPx9AllBytesASM)
}

nop_x18 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, NOPx18AllBytesASM)
}

read_x1 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_x1)
}

read_x2 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_x2)
}

read_x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_x3)
}

read_x4 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_x4)
}

write_x1 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Write_x1)
}

write_x2 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Write_x2)
}

write_x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Write_x3)
}

write_x4 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Write_x4)
}

read_4x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_4x3)
}

read_8x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_8x3)
}

read_16x2 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_16x2)
}

read_16x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_16x3)
}

read_32x2 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_32x2)
}

read_32x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_32x3)
}

read_64x3 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Read_64x3)
}

cache_4k :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Cache_4K)
}

cache_64k :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Cache_64K)
}

cache_1m :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Cache_1M)
}

cache_16m :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Cache_16M)
}

cache_256m :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Cache_256M)
}

cache_4g :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_asm(t, path, Cache_4G)
}

conditional_nop :: proc(t: ^tester, dest: []byte) {
	size := i64(len(dest))

	for is_testing(t) {
		begin_time(t)
		ConditionalNOP(raw_data(dest), uint(size))
		end_time(t, u64(size))

		if t.target_processed_bytes == 0 {
			t.target_processed_bytes = size
			count_bytes(t, u64(size))
		}
		count_bytes(t, u64(size))
	}
}

alignment_64 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_alignment_test(t, path, NOPAligned64)
}

alignment_4 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_alignment_test(t, path, NOPAligned4)
}

alignment_16 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_alignment_test(t, path, NOPAligned16)
}

alignment_32 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_alignment_test(t, path, NOPAligned32)
}

alignment_60 :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_alignment_test(t, path, NOPAligned60)
}

rat_add :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_alignment_test(t, path, RATAdd)
}

rat_mov_add :: proc(t: ^tester, path: string, with_malloc: bool) {
	custom_alignment_test(t, path, RATMovAdd)
}
