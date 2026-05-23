package json

import (
	"fmt"
	"unicode"
)

type int_lexer struct {
	buffer []rune
	tokens []token
}

func (l int_lexer) get_tokens() []token {
	return l.tokens
}

func (l int_lexer) lex(r rune) (clean_lexer, error) {
	if unicode.IsNumber(r) {
		l.buffer = append(l.buffer, r)
		return l, nil
	}

	if r == '.' {
		buffer := append(l.buffer, r)
		return float_lexer{buffer: buffer, tokens: l.tokens}, nil
	}

	if !unicode.IsSpace(r) && r != ',' {
		return l, fmt.Errorf("invalid json: malformed integer")
	}

	l.tokens = append(l.tokens, token{
		kind:  "int",
		value: string(l.buffer),
	})

	l.buffer = nil

	if r == ',' {
		l.tokens = append(l.tokens, comma)
	}

	return normal_lexer{buffer: l.buffer, tokens: l.tokens}, nil
}

func (l int_lexer) typeof() string {
	return "int"
}
