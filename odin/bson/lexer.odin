package bson

import "core:strconv"
import "core:unicode"
import "core:unicode/utf8"

lex_runes :: proc(runes: []rune) -> (tokens: [dynamic]Token, err: Error) {
	l: Lexer

	for r in runes {
		switch l.Status {
		case .Normal:
			lex_normal(&l, r) or_return
		case .Int:
			lex_int(&l, r) or_return
		case .Float:
			lex_float(&l, r) or_return
		case .String:
			lex_string(&l, r) or_return
		}
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

	if !unicode.is_space(r) && r != ',' {
		return .Invalid_Int
	}

	s := utf8.runes_to_string(lexer.Buffer[:])
	token, ok := strconv.parse_int(s)
	if !ok {
		return .Invalid_Int
	}

	append(&lexer.Tokens, token)
	clear(&lexer.Buffer)
	lexer.Status = .Normal

	if r == ',' {
		append(&lexer.Tokens, ControlToken.Comma)
	}

	return .nil
}

lex_float :: proc(lexer: ^Lexer, r: rune) -> Error {
	if unicode.is_number(r) {
		append(&lexer.Buffer, r)
		return .nil
	}

	if !unicode.is_space(r) && r != ',' {
		return .Invalid_Float
	}

	if lexer.Buffer[len(lexer.Buffer) - 1] == '.' {
		return .Invalid_Float
	}

	s := utf8.runes_to_string(lexer.Buffer[:])
	token, ok := strconv.parse_f64(s)
	if !ok {
		return .Invalid_Float
	}

	append(&lexer.Tokens, token)
	clear(&lexer.Buffer)
	lexer.Status = .Normal

	if r == ',' {
		append(&lexer.Tokens, ControlToken.Comma)
	}

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
