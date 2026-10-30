package bson

import "core:strconv"
import "core:unicode"
import "core:unicode/utf8"

lex_runes :: proc(runes: []rune) -> (tokens: [dynamic]Token, err: Error) {
	l: Lexer
	defer delete(l.Buffer)
	defer if err != nil {
		delete(l.Tokens)
	}

	for r in runes {
		switch l.Status {
		case .Normal:
			err = lex_normal(&l, r)
		case .Int:
			err = lex_int(&l, r)
		case .Float:
			err = lex_float(&l, r)
		case .String:
			err = lex_string(&l, r)
		}
		if err != nil {
			return
		}
	}

	switch l.Status {
	case .Normal:
	case .Int:
		err = finish_int(&l)
	case .Float:
		err = finish_float(&l)
	case .String:
		err = .Invalid_String
	}
	if err != nil {
		return
	}

	return l.Tokens, .nil
}

lex_normal :: proc(lexer: ^Lexer, r: rune) -> Error {
	if unicode.is_letter(r) {
		return .Invalid_String
	}

	if unicode.is_space(r) {
		return .nil
	}

	if unicode.is_number(r) || r == '-' {
		lexer.Status = .Int
		append(&lexer.Buffer, r)
		return .nil
	}

	switch r {
	case '"':
		lexer.Status = .String
	case '{':
		append(&lexer.Tokens, ControlToken.Object_Start)
	case '}':
		append(&lexer.Tokens, ControlToken.Object_End)
	case '[':
		append(&lexer.Tokens, ControlToken.Array_Start)
	case ']':
		append(&lexer.Tokens, ControlToken.Array_End)
	case ':':
		append(&lexer.Tokens, ControlToken.Colon)
	case ',':
		append(&lexer.Tokens, ControlToken.Comma)
	case:
		return .Unexpected_Rune
	}

	return .nil
}

lex_int :: proc(lexer: ^Lexer, r: rune) -> Error {
	if unicode.is_number(r) {
		append(&lexer.Buffer, r)
		return .nil
	}

	if r == '.' {
		append(&lexer.Buffer, r)
		lexer.Status = .Float
		return .nil
	}

	if !is_number_end(r) {
		return .Invalid_Int
	}

	finish_int(lexer) or_return
	emit_number_end(lexer, r)
	return .nil
}

lex_float :: proc(lexer: ^Lexer, r: rune) -> Error {
	if unicode.is_number(r) {
		append(&lexer.Buffer, r)
		return .nil
	}

	if !is_number_end(r) {
		return .Invalid_Float
	}

	finish_float(lexer) or_return
	emit_number_end(lexer, r)
	return .nil
}

lex_string :: proc(lexer: ^Lexer, r: rune) -> Error {
	if r != '"' {
		append(&lexer.Buffer, r)
		return .nil
	}

	token := utf8.runes_to_string(lexer.Buffer[:])
	append(&lexer.Tokens, token)
	clear(&lexer.Buffer)
	lexer.Status = .Normal
	return .nil
}

finish_int :: proc(lexer: ^Lexer) -> Error {
	s := utf8.runes_to_string(lexer.Buffer[:])
	defer delete(s)

	if len(s) == 0 {
		return .Invalid_Int
	}

	if s[0] == '-' {
		token, ok := strconv.parse_int(s)
		if !ok {
			return .Invalid_Int
		}
		append(&lexer.Tokens, token)
	} else if token, ok := parse_u64_checked(s); ok {
		append(&lexer.Tokens, token)
	} else {
		return .Invalid_Int
	}

	clear(&lexer.Buffer)
	lexer.Status = .Normal
	return .nil
}

parse_u64_checked :: proc(s: string) -> (value: u64, ok: bool) {
	if len(s) == 0 {
		return 0, false
	}

	for r in s {
		if r < '0' || r > '9' {
			return 0, false
		}
		digit := u64(r - '0')
		if value > (max(u64) - digit) / 10 {
			return 0, false
		}
		value = value * 10 + digit
	}

	return value, true
}

finish_float :: proc(lexer: ^Lexer) -> Error {
	if len(lexer.Buffer) == 0 || lexer.Buffer[len(lexer.Buffer) - 1] == '.' {
		return .Invalid_Float
	}

	s := utf8.runes_to_string(lexer.Buffer[:])
	defer delete(s)

	token, ok := strconv.parse_f64(s)
	if !ok {
		return .Invalid_Float
	}

	append(&lexer.Tokens, token)
	clear(&lexer.Buffer)
	lexer.Status = .Normal
	return .nil
}

is_number_end :: proc(r: rune) -> bool {
	return unicode.is_space(r) || r == ',' || r == '}' || r == ']'
}

emit_number_end :: proc(lexer: ^Lexer, r: rune) {
	switch r {
	case ',':
		append(&lexer.Tokens, ControlToken.Comma)
	case '}':
		append(&lexer.Tokens, ControlToken.Object_End)
	case ']':
		append(&lexer.Tokens, ControlToken.Array_End)
	}
}
