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
	parser.dest = reflect.deref(dest)
	for token in tokens {
		read_token(&parser, token)
	}

	return .nil
}

read_token :: proc(parser: ^Parser, token: Token) -> Error {
	#partial switch parser.status {
	case .Value:
		return read_value(parser, token)
	case .String:
		return read_string(parser, token)
	}

	return .nil
}

read_value :: proc(p: ^Parser, token: Token) -> Error {
	switch value in token {
	case ControlToken:
		return read_control_token(p, value)
	case int:
	case f64:
		if p.dest == nil {
			return .EmptyDestStack
		}

		if p.key == "" {
			(^f64)(p.dest.data)^ = value
			break
		}

		field := reflect.struct_field_by_name(p.dest.id, p.key)
		if field.name == "" {
			break
		}

		field_address := rawptr(uintptr(p.dest.data) + field.offset)
		(^f64)(field_address)^ = value
		p.key = ""

	case string:
		if len(p.dest_stack) == 0 {
			return .EmptyDestStack
		}
		dest := pop(&p.dest_stack)

		p.key = value
		append(&p.status_stack, p.status)

		p.status = .String
	}

	return .nil
}

read_control_token :: proc(p: ^Parser, token: ControlToken) -> Error {
	assert(p.status == .Value)

	switch token {
	case .Array_Start:
		append(&p.status_stack, p.status)
		p.status = .Array
		return .nil
	case .Array_End:
		return .Unexpected_End_Of_Array
	case .Colon:
		return .Unexpected_Colon
	case .Comma:
		return .Unexpected_Comma
	case .Object_Start:
		append(&p.status_stack, p.status)
		return .nil
	case .Object_End:
		return .Unexpected_End_Of_Object
	}

	return .nil
}

read_string :: proc(p: ^Parser, token: Token) -> Error {
	#partial switch control in token {
	case ControlToken:
		#partial switch control {
		case .Colon:
			p.status = .Value
			break
		case .Comma:
			previous_status := pop(&p.status_stack)
			if previous_status != .Array {
				return .Unexpected_Comma
			}

		// TODO: Implement for robust comma handling

		case .Object_End:
			dest := pop(&p.dest_stack)

			value := pop(&p.key_stack)
			if len(p.key_stack) == 0 {
				(^string)(dest.data)^ = value
				break
			}

			key := pop(&p.key_stack)
			field := reflect.struct_field_by_name(dest.id, key)
			if field.name == "" {
				break
			}

			field_address := rawptr(uintptr(dest.data) + field.offset)
			(^string)(field_address)^ = value

		case:
			return .Invalid_Control_Token
		}
	case:
		return .Expected_Control_Token
	}

	return .nil
}
