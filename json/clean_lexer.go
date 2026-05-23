package json

import (
	"fmt"
	"haversine-i-barely-know-her/metrics"
)

type clean_lexer interface {
	get_tokens() []token
	lex(r rune) (clean_lexer, error)
	typeof() string
}

func lex_runes_cleanly(runes []rune) ([]token, error) {
	start := metrics.Start(metrics.LexJSONClean)
	defer metrics.End(start, metrics.LexJSONClean)

	var lexer clean_lexer = normal_lexer{}
	var err error

	for _, r := range runes {
		lexer, err = lexer.lex(r)
		if err != nil {
			return nil, err
		}
	}

	if lexer.typeof() != "normal" {
		return nil, fmt.Errorf("invalid lexer status: %s\n", lexer.typeof())
	}

	return lexer.get_tokens(), nil
}
