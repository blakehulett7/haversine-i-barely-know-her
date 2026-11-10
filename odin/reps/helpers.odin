package main

import "core:crypto"
import "core:math/rand"

fill_buffer :: proc(dest: []byte, pattern: branch_pattern) {
	if pattern == .mathrand {
		_ = rand.read(dest)
		return
	}

	if pattern == .cryptrand {
		crypto.rand_bytes(dest)
		return
	}

	for i in 0 ..< len(dest) {
		value: byte
		switch pattern {
		case .never_taken:
			value = 0
		case .always_taken:
			value = 1
		case .every_2:
			value = u8(i % 2 == 0)
		case .every_3:
			value = u8(i % 3 == 0)
		case .every_4:
			value = u8(i % 4 == 0)
		case .mathrand:
		case .cryptrand:
		}

		dest[i] = value
	}
}
