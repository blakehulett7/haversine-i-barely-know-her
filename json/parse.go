package json

import (
	"fmt"
	"reflect"
)

func Parse(dest any, data []byte) error {
	v := reflect.ValueOf(dest)
	if v.Kind() != reflect.Pointer {
		return fmt.Errorf("invalid destination, use a pointer to a struct")
	}

	s := string(data)
	runes := []rune(s)

	tokens, err := lexRunes(runes)
	if err != nil {
		return err
	}

	fmt.Println(tokens)

	return nil
}

type parser struct {
	object_stack stack
	array_stack  stack
}

func newParser() parser {
	return parser{
		object_stack: newStack(),
		array_stack:  newStack(),
	}
}
