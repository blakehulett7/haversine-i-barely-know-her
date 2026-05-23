package json

import (
	"fmt"
	"unicode"
)

type normal_lexer struct {
	buffer []rune
	tokens []token
}

func (l normal_lexer) get_tokens() []token {
	return l.tokens
}

func (l normal_lexer) lex(r rune) (clean_lexer, error) {
	if unicode.IsLetter(r) {
		return l, fmt.Errorf("invalid json: quotes required around strings")
	}

	if unicode.IsSpace(r) {
		return l, nil
	}

	if unicode.IsNumber(r) || r == '-' {
		return int_lexer{buffer: []rune{r}, tokens: l.tokens}, nil
	}

	switch r {
	default:
		return l, fmt.Errorf("invalid json: unexpected rune %q", r)
	case '"':
		return string_lexer{buffer: l.buffer, tokens: l.tokens}, nil
	case '{':
		l.tokens = append(l.tokens, object_start)
	case '}':
		l.tokens = append(l.tokens, object_end)
	case '[':
		l.tokens = append(l.tokens, array_start)
	case ']':
		l.tokens = append(l.tokens, array_end)
	case ':':
		l.tokens = append(l.tokens, colon)
	case ',':
		l.tokens = append(l.tokens, comma)
	}

	return l, nil
}

func (l normal_lexer) typeof() string {
	return "normal"
}
