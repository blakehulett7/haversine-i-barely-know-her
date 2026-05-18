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

	fmt.Println(v.Elem().Kind())
	t := v.Elem().Type()
	fmt.Println(v.Elem().Type().NumField())

	for i := 0; i < t.NumField(); i++ {
		field := t.Field(i)
		fmt.Printf("%+v\n", field)
		fmt.Println(field.Tag.Get("json"))
		fmt.Println(field.Type)
		fmt.Println(field.Type.Kind())
		for j := 0; j < field.Type.Elem().NumField(); j++ {
			nested := field.Type.Elem().Field(j)
			fmt.Println(nested)
		}
	}

	s := string(data)
	runes := []rune(s)

	tokens, err := lexRunes(runes)
	if err != nil {
		return err
	}

	fmt.Println(tokens)

	parser := newParser()
	parser.dest_stack.push(t)
	for _, t := range tokens {
		fmt.Println(parser.status, parser.key_stack, t)
		err = parser.read(t)
	}

	return nil
}

type parser struct {
	status      parser_status
	valid_close bool
	valid_open  bool

	dest_stack stack[reflect.Type]
	key_stack  stack[string]
	final      any

	dest reflect.Value
}

func newParser() *parser {
	return &parser{
		status:     parse_value,
		dest_stack: newStack[reflect.Type](),
		key_stack:  newStack[string](),
	}
}

func (p *parser) read(token token) error {
	switch p.status {
	default:
		return fmt.Errorf("invalid parser status")
	case parse_array:
		return p.read_array(token)
	case parse_key:
		return p.read_key(token)
	case parse_object:
		return p.read_object(token)
	case parse_value:
		return p.read_value(token)
	}
}

func (p *parser) read_array(t token) error {
	switch t.kind {
	default:
		return fmt.Errorf("invalid json: unexpected token %v", t)
	case "start":
	case "end":
	case "string", "int", "float":
	}

	return nil
}

func (p *parser) read_key(t token) error {
	if t.kind != "control" && t.value != ":" {
		return fmt.Errorf("invalid json: key not terminated got %v", t)
	}
	p.status = parse_value

	key := p.key_stack.peek()
	dest := p.dest_stack.peek()
	field, ok := dest.FieldByName(key)

	if !ok {
		return fmt.Errorf("no struct field matches the given key: %s\n", key)
	}

	if dest.Kind() != reflect.Struct {
		return fmt.Errorf("invalid parser status, must be in a struct to read a key")
	}

	p.dest_stack.push(field.Type)

	return nil
}

func (p *parser) read_object(t token) error {
	switch t.kind {
	default:
		return fmt.Errorf("invalid json: expected key but got %v", t)
	case "string":
		p.key_stack.push(t.value)
		p.status = parse_key
		return nil
	}

	return nil
}

func (p *parser) read_value(t token) error {
	switch t.kind {
	default:
		fallthrough
	case "control":
		fallthrough
	case "end":
		return fmt.Errorf("invalid json: unexpected token %v", t)
	case "start":
		if t.value == "array" {
			p.status = parse_array
			return nil
		}

		if t.value == "object" {
			p.status = parse_object
			return nil
		}
	case "string", "int", "float":
	}

	return nil
}

type parser_status byte

const (
	parse_array parser_status = iota
	parse_key
	parse_object
	parse_value
)

func (ps parser_status) String() string {
	switch ps {
	default:
		return "invalid status"
	case parse_array:
		return "parse_array"
	case parse_key:
		return "parse_key"
	case parse_object:
		return "parse_object"
	case parse_value:
		return "parse_value"
	}
}
