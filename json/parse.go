package json

import (
	"fmt"
	"haversine-i-barely-know-her/metrics"
	"haversine-i-barely-know-her/stack"
	"reflect"
	"strconv"

	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

func Parse(dest any, data []byte) error {
	start := metrics.Start(metrics.ParseJSON)
	defer metrics.End(start, uint64(len(data)), metrics.ParseJSON)

	v := reflect.ValueOf(dest)
	if v.Kind() != reflect.Pointer {
		return fmt.Errorf("invalid destination, use a pointer to a struct")
	}

	s := string(data)
	runes := []rune(s)

	// tokens, err := lex_runes_cleanly(runes)
	tokens, err := lexRunes(runes)

	if err != nil {
		return err
	}

	parser := newParser()
	parser.dest_stack.Push(v.Elem())
	for _, t := range tokens {
		err = parser.read(t)
		if err != nil {
			return err
		}
	}

	return nil
}

type parser struct {
	status      parser_status
	valid_close bool
	valid_open  bool

	dest_stack   stack.Stack[reflect.Value]
	key_stack    stack.Stack[string]
	status_stack stack.Stack[parser_status]

	final any
	dest  reflect.Value
}

func newParser() *parser {
	return &parser{
		status:       parse_value,
		dest_stack:   stack.New[reflect.Value](),
		key_stack:    stack.New[string](),
		status_stack: stack.New[parser_status](),
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
	case "control":

		if t.value != "," {
			return fmt.Errorf("invalid json: unexpected :")
		}

		return nil

	case "end":
	case "start":
		if t.value == "object" {
			p.status_stack.Push(parse_array)
			p.status = parse_object

			dest := p.dest_stack.Peek()

			obj := reflect.New(dest.Type().Elem()).Elem()
			p.dest_stack.Push(obj)
			return nil
		}

		return nil
	case "string", "int", "float":
	}

	return nil
}

func (p *parser) read_key(t token) error {
	if t.kind != "control" && t.value != ":" {
		return fmt.Errorf("invalid json: key not terminated got %v", t)
	}
	p.status = parse_value

	dest := p.dest_stack.Peek()

	if dest.Kind() != reflect.Struct {
		return fmt.Errorf("invalid parser status, must be in a struct to read a key")
	}

	return nil
}

func (p *parser) read_object(t token) error {
	switch t.kind {
	default:
		return fmt.Errorf("invalid json: expected key but got %v", t)
	case "string":
		key := cases.Title(language.English).String(t.value)
		p.key_stack.Push(key)
		p.status_stack.Push(parse_object)
		p.status = parse_key
		return nil
	}
}

func (p *parser) read_value(t token) error {
	switch t.kind {
	default:
		return fmt.Errorf("invalid json: unexpected token %v", t)
	case "end":

		obj := p.dest_stack.Pop()

		p.key_stack.Pop()
		p.status_stack.Pop()
		p.status = p.status_stack.Pop()

		dest := p.dest_stack.Peek()
		dest.Set(reflect.Append(dest, obj))

	case "control":

		if t.value == ":" {
			return fmt.Errorf("invalid json: unexpected :")
		}

		p.key_stack.Pop()
		p.status = p.status_stack.Pop()

	case "start":
		if t.value == "object" {
			p.status_stack.Push(p.status)
			p.status = parse_object
			return nil
		}

		if t.value == "array" {
			p.status_stack.Push(p.status)
			p.status = parse_array

			key := p.key_stack.Peek()
			dest := p.dest_stack.Peek()
			field := dest.FieldByName(key)

			if field.Kind() != reflect.Slice {
				return fmt.Errorf("invalid parser status, must be in a slice to read an array")
			}

			p.dest_stack.Push(field)
			return nil
		}

	case "float":
		key := p.key_stack.Peek()
		dest := p.dest_stack.Peek()
		field := dest.FieldByName(key)

		f, err := strconv.ParseFloat(t.value, 64)
		if err != nil {
			return fmt.Errorf("invalid json: could not parse float %v\n", err)
		}
		field.SetFloat(f)

	case "string", "int":
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
