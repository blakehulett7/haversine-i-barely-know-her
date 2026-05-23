package json

import (
	"fmt"
	"unicode"
)

type float_lexer struct {
	buffer []rune
	tokens []token
}

func (l float_lexer) get_tokens() []token {
	return l.tokens
}

func (l float_lexer) lex(r rune) (clean_lexer, error) {
	if unicode.IsNumber(r) {
		l.buffer = append(l.buffer, r)
		return l, nil
	}

	if !unicode.IsSpace(r) && r != ',' {
		return l, fmt.Errorf("invalid json: malformed float")
	}

	if l.buffer[len(l.buffer)-1] == '.' {
		return l, fmt.Errorf("invalid json: float cannot end with a '.'")
	}

	l.tokens = append(l.tokens, token{
		kind:  "float",
		value: string(l.buffer),
	})

	l.buffer = nil

	if r == ',' {
		l.tokens = append(l.tokens, comma)
	}

	return normal_lexer{buffer: l.buffer, tokens: l.tokens}, nil
}

func (l float_lexer) typeof() string {
	return "float"
}
