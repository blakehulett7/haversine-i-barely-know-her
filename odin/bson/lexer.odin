package bson

import "core:unicode"

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
		return nil
	}

	if unicode.is_number(r) || r == '-' {
		lexer.Status = .Int
		append(&lexer.Buffer, r)
		return nil
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

lex_int :: proc(lexer: ^Lexer, r: rune) -> Error {return .nil}
lex_float :: proc(lexer: ^Lexer, r: rune) -> Error {return .nil}
lex_string :: proc(lexer: ^Lexer, r: rune) -> Error {return .nil}
