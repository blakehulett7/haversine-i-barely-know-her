package bson

import "base:runtime"
import "core:reflect"
import "core:unicode/utf8"

parse :: proc(dest: any, data: []byte) -> Error {
	info := type_info_of(dest.id)

	if !reflect.is_pointer(info) {
		return .Dest_Not_Pointer
	}

	s := string(data)
	runes := utf8.string_to_runes(s)
	defer delete(runes)

	tokens := lex_runes(runes) or_return
	defer delete(tokens)

	parser: Parser
	defer {
		delete(parser.dest_stack)
		delete(parser.key_stack)
		delete(parser.status_stack)
	}

	parser.dest = reflect.deref(dest)
	for token in tokens {
		read_token(&parser, token) or_return
	}

	return .nil
}

read_token :: proc(parser: ^Parser, token: Token) -> Error {
	switch parser.status {
	case .Value:
		return read_value(parser, token)
	case .String:
		return read_string(parser, token)
	case .Array:
		return read_array(parser, token)
	}

	return .nil
}

read_value :: proc(p: ^Parser, token: Token) -> Error {
	switch value in token {
	case ControlToken:
		return read_control_token(p, value)
	case int:
		return write_number(p, token)
	case f64:
		return write_number(p, token)
	case string:
		if p.dest == nil {
			return .EmptyDest
		}

		if p.key != "" {
			append(&p.key_stack, p.key)
		}

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
		return open_array(p)
	case .Array_End:
		return .Unexpected_End_Of_Array
	case .Colon:
		return .Unexpected_Colon
	case .Comma:
		p.key = ""
		return .nil
	case .Object_Start:
		return open_object(p)
	case .Object_End:
		return close_container(p, .Unexpected_End_Of_Object)
	}

	return .nil
}

read_string :: proc(p: ^Parser, token: Token) -> Error {
	control, ok := token.(ControlToken)
	if !ok {
		return .Expected_Control_Token
	}

	switch control {
	case .Colon:
		if len(p.status_stack) == 0 {
			return .Unexpected_Colon
		}
		p.status = pop(&p.status_stack)
		if p.status != .Value {
			return .Unexpected_Colon
		}
		return .nil
	case .Comma:
		assign_string(p) or_return
		p.key = ""
		return .nil
	case .Object_End:
		assign_string(p) or_return
		return close_container(p, .Unexpected_End_Of_Object)
	case .Array_End:
		assign_string(p) or_return
		return close_container(p, .Unexpected_End_Of_Array)
	case .Array_Start, .Object_Start:
		return .Invalid_Control_Token
	}

	return .Invalid_Control_Token
}

read_array :: proc(p: ^Parser, token: Token) -> Error {
	control, ok := token.(ControlToken)
	if !ok {
		return .Unexpected_Token
	}

	switch control {
	case .Object_Start:
		return begin_array_element(p)
	case .Comma:
		return .nil
	case .Array_End:
		return close_container(p, .Unexpected_End_Of_Array)
	case .Array_Start, .Colon, .Object_End:
		return .Unexpected_Token
	}

	return .Unexpected_Token
}

open_object :: proc(p: ^Parser) -> Error {
	if p.dest == nil {
		return .EmptyDest
	}

	parent := p.dest
	next := p.dest
	if p.key != "" {
		field := reflect.struct_field_by_name(p.dest.id, p.key)
		if field.name == "" {
			return .Unexpected_Token
		}
		if _, ok := reflect.type_info_base(field.type).variant.(reflect.Type_Info_Struct); !ok {
			return .Unexpected_Token
		}
		next = any{rawptr(uintptr(p.dest.data) + field.offset), field.type.id}
	}

	append(&p.dest_stack, parent)
	append(&p.status_stack, p.status)
	p.dest = next
	p.key = ""
	return .nil
}

open_array :: proc(p: ^Parser) -> Error {
	if p.dest == nil {
		return .EmptyDest
	}

	array_dest := p.dest
	if p.key != "" {
		field := reflect.struct_field_by_name(p.dest.id, p.key)
		if field.name == "" {
			return .Unexpected_Token
		}
		if !reflect.is_dynamic_array(field.type) {
			return .Unexpected_Token
		}
		array_dest = any{rawptr(uintptr(p.dest.data) + field.offset), field.type.id}
	} else if !reflect.is_dynamic_array(type_info_of(p.dest.id)) {
		return .Unexpected_Token
	}

	append(&p.dest_stack, p.dest)
	append(&p.status_stack, p.status)
	p.dest = array_dest
	p.key = ""
	p.status = .Array
	return .nil
}

begin_array_element :: proc(p: ^Parser) -> Error {
	if p.dest == nil {
		return .EmptyDest
	}

	info := reflect.type_info_base(type_info_of(p.dest.id))
	arr, ok := info.variant.(reflect.Type_Info_Dynamic_Array)
	if !ok {
		return .Unexpected_Token
	}

	raw := (^runtime.Raw_Dynamic_Array)(p.dest.data)
	before := raw.len
	n := runtime.__dynamic_array_append_nothing(p.dest.data, arr.elem.size, arr.elem.align)
	if n != before + 1 {
		return .Unexpected_Token
	}

	data := rawptr(uintptr(raw.data) + uintptr(arr.elem.size * (n - 1)))
	append(&p.dest_stack, p.dest)
	append(&p.status_stack, p.status)
	p.dest = any{data, arr.elem.id}
	p.status = .Value
	p.key = ""
	return .nil
}

close_container :: proc(p: ^Parser, empty_err: Error) -> Error {
	if len(p.dest_stack) == 0 || len(p.status_stack) == 0 {
		return empty_err
	}

	p.dest = pop(&p.dest_stack)
	p.status = pop(&p.status_stack)
	p.key = ""
	return .nil
}

assign_string :: proc(p: ^Parser) -> Error {
	value := p.key
	if len(p.status_stack) == 0 {
		return .Unexpected_Token
	}

	p.status = pop(&p.status_stack)
	p.key = ""

	if p.dest == nil {
		return .EmptyDest
	}

	if len(p.key_stack) == 0 {
		return write_string(p.dest.data, p.dest.id, value)
	}

	key := pop(&p.key_stack)
	field := reflect.struct_field_by_name(p.dest.id, key)
	if field.name == "" {
		return .nil
	}

	field_address := rawptr(uintptr(p.dest.data) + field.offset)
	return write_string(field_address, field.type.id, value)
}

write_string :: proc(addr: rawptr, id: typeid, value: string) -> Error {
	info := reflect.type_info_base(type_info_of(id))
	str, ok := info.variant.(reflect.Type_Info_String)
	if !ok || str.is_cstring || str.encoding != .UTF_8 {
		return .Unexpected_Token
	}

	(^string)(addr)^ = value
	return .nil
}

write_number :: proc(p: ^Parser, token: Token) -> Error {
	if p.dest == nil {
		return .EmptyDest
	}

	addr := p.dest.data
	id := p.dest.id
	if p.key != "" {
		field := reflect.struct_field_by_name(p.dest.id, p.key)
		if field.name == "" {
			p.key = ""
			return .nil
		}

		addr = rawptr(uintptr(p.dest.data) + field.offset)
		id = field.type.id
	}

	switch value in token {
	case f64:
		write_f64(addr, id, value) or_return
	case int:
		write_int(addr, id, value) or_return
	case ControlToken, string:
		return .Unexpected_Token
	}

	p.key = ""
	return .nil
}

write_f64 :: proc(addr: rawptr, id: typeid, value: f64) -> Error {
	info := reflect.type_info_base(type_info_of(id))
	_, ok := info.variant.(reflect.Type_Info_Float)
	if !ok || info.size != size_of(f64) {
		return .Unexpected_Token
	}

	(^f64)(addr)^ = value
	return .nil
}

write_int :: proc(addr: rawptr, id: typeid, value: int) -> Error {
	info := reflect.type_info_base(type_info_of(id))
	#partial switch v in info.variant {
	case reflect.Type_Info_Float:
		if info.size != size_of(f64) {
			return .Unexpected_Token
		}
		(^f64)(addr)^ = f64(value)
	case reflect.Type_Info_Integer:
		if info.size != size_of(int) || !v.signed {
			return .Unexpected_Token
		}
		(^int)(addr)^ = value
	case:
		return .Unexpected_Token
	}

	return .nil
}
