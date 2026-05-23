package json

type string_lexer struct {
	buffer []rune
	tokens []token
}

func (l string_lexer) get_tokens() []token {
	return l.tokens
}

func (l string_lexer) lex(r rune) (clean_lexer, error) {
	if r != '"' {
		l.buffer = append(l.buffer, r)
		return l, nil
	}

	l.tokens = append(l.tokens, token{
		kind:  "string",
		value: string(l.buffer),
	})

	l.buffer = nil
	return normal_lexer{buffer: l.buffer, tokens: l.tokens}, nil
}

func (l string_lexer) typeof() string {
	return "string"
}
