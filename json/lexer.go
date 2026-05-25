package json

import (
	"fmt"
	"haversine-i-barely-know-her/metrics"
	"unicode"
)

type lexer struct {
	status lexer_status

	buffer []rune
	tokens []token
}

func newLexer() lexer {
	return lexer{
		status: lexer_normal,
	}
}

func lexRunes(runes []rune) ([]token, error) {
	start := metrics.Start(metrics.LexJSON)
	defer metrics.End(start, uint64(len(runes)*4), metrics.LexJSON)

	lexer := newLexer()

	for _, r := range runes {
		var err error

		switch lexer.status {
		default:
			return nil, fmt.Errorf("invalid lexer status: %v\n", lexer.status)
		case lexer_normal:
			err = lexNormal(&lexer, r)
		case int_open:
			err = lexInt(&lexer, r)
		case float_open:
			err = lexFloat(&lexer, r)
		case string_open:
			err = lexString(&lexer, r)
		}

		if err != nil {
			return nil, err
		}
	}

	if lexer.status != lexer_normal {
		return nil, fmt.Errorf("invalid lexer status: %v\n", lexer.status)
	}

	return lexer.tokens, nil
}

func lexNormal(lexer *lexer, r rune) error {
	if unicode.IsLetter(r) {
		return fmt.Errorf("invalid json: quotes required around strings")
	}

	if unicode.IsSpace(r) {
		return nil
	}

	if unicode.IsNumber(r) || r == '-' {
		lexer.status = int_open
		lexer.buffer = append(lexer.buffer, r)
		return nil
	}

	switch r {
	default:
		return fmt.Errorf("invalid json: unexpected rune %q", r)
	case '"':
		lexer.status = string_open
	case '{':
		lexer.tokens = append(lexer.tokens, object_start)
	case '}':
		lexer.tokens = append(lexer.tokens, object_end)
	case '[':
		lexer.tokens = append(lexer.tokens, array_start)
	case ']':
		lexer.tokens = append(lexer.tokens, array_end)
	case ':':
		lexer.tokens = append(lexer.tokens, colon)
	case ',':
		lexer.tokens = append(lexer.tokens, comma)
	}

	return nil
}

func lexInt(lexer *lexer, r rune) error {
	if unicode.IsNumber(r) {
		lexer.buffer = append(lexer.buffer, r)
		return nil
	}

	if r == '.' {
		lexer.buffer = append(lexer.buffer, r)
		lexer.status = float_open
		return nil
	}

	if !unicode.IsSpace(r) && r != ',' {
		return fmt.Errorf("invalid json: malformed integer")
	}

	lexer.tokens = append(lexer.tokens, token{
		kind:  "int",
		value: string(lexer.buffer),
	})

	lexer.buffer = nil
	lexer.status = lexer_normal

	if r == ',' {
		lexer.tokens = append(lexer.tokens, comma)
	}

	return nil
}

func lexFloat(lexer *lexer, r rune) error {
	if unicode.IsNumber(r) {
		lexer.buffer = append(lexer.buffer, r)
		return nil
	}

	if !unicode.IsSpace(r) && r != ',' {
		return fmt.Errorf("invalid json: malformed float")
	}

	if lexer.buffer[len(lexer.buffer)-1] == '.' {
		return fmt.Errorf("invalid json: float cannot end with a '.'")
	}

	lexer.tokens = append(lexer.tokens, token{
		kind:  "float",
		value: string(lexer.buffer),
	})

	lexer.buffer = nil
	lexer.status = lexer_normal

	if r == ',' {
		lexer.tokens = append(lexer.tokens, comma)
	}

	return nil
}

func lexString(lexer *lexer, r rune) error {
	if r != '"' {
		lexer.buffer = append(lexer.buffer, r)
		return nil
	}

	lexer.tokens = append(lexer.tokens, token{
		kind:  "string",
		value: string(lexer.buffer),
	})

	lexer.buffer = nil
	lexer.status = lexer_normal
	return nil
}

type lexer_status byte

const (
	lexer_normal lexer_status = iota
	int_open
	float_open
	string_open
)

func (ls lexer_status) String() string {
	switch ls {
	default:
		return ""
	case lexer_normal:
		return "lexer_normal"
	case int_open:
		return "int_open"
	case float_open:
		return "float_open"
	case string_open:
		return "string_open"
	}
}
