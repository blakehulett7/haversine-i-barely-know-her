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
	append(&parser.dest_stack, dest)
	for token in tokens {
		read_token(&parser, token)
	}

	return .nil
}

read_token :: proc(parser: ^Parser, token: Token) -> Error {
	switch token {
	case ControlToken.Object_Start:
		append(&parser.dest_stack, parser.dest_stack[len(parser.dest_stack) - 1])
		append(&parser.key_stack, "")
	case ControlToken.Object_End:
		clear(&parser.dest_stack)
		clear(&parser.key_stack)
	case ControlToken.Comma:
	//
	case ControlToken.Colon:
	//
	}
	return .nil
}

