package bson

import "core:fmt"
import "core:reflect"
import "core:unicode/utf8"

parse :: proc(dest: any, data: []byte) -> Error {
	fmt.println("Ave Maria")

	info := type_info_of(dest.id)

	if !reflect.is_pointer(info) {
		return .Dest_Not_Pointer
	}

	s := string(data)
	runes := utf8.string_to_runes(s)
	tokens := lex_runes(runes) or_return

	parser: Parser
	for token in tokens {
		read_token(&parser, token)
	}

	return .nil
}
