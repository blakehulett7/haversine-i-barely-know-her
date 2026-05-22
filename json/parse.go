package json

import (
	"fmt"
	"haversine-i-barely-know-her/metrics"
	"reflect"
	"strconv"
	"time"

	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

func Parse(dest any, data []byte) error {
	start := time.Now()
	defer metrics.ReportMetrics(start, metrics.ParseJSON)

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

	parser := newParser()
	parser.dest_stack.push(v.Elem())
	for _, t := range tokens {
		// fmt.Println(parser.status, parser.key_stack, parser.status_stack, t)
		err = parser.read(t)

		if err != nil {
			return err
		}
	}

	// fmt.Println()

	return nil
}

type parser struct {
	status      parser_status
	valid_close bool
	valid_open  bool

	dest_stack   stack[reflect.Value]
	key_stack    stack[string]
	status_stack stack[parser_status]

	final any
	dest  reflect.Value
}

func newParser() *parser {
	return &parser{
		status:       parse_value,
		dest_stack:   newStack[reflect.Value](),
		key_stack:    newStack[string](),
		status_stack: newStack[parser_status](),
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
			p.status_stack.push(parse_array)
			p.status = parse_object

			dest := p.dest_stack.peek()

			obj := reflect.New(dest.Type().Elem()).Elem()
			p.dest_stack.push(obj)
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

	dest := p.dest_stack.peek()

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
		p.key_stack.push(key)
		p.status_stack.push(parse_object)
		p.status = parse_key
		return nil
	}
}

func (p *parser) read_value(t token) error {
	switch t.kind {
	default:
		return fmt.Errorf("invalid json: unexpected token %v", t)
	case "end":

		obj := p.dest_stack.pop()

		p.key_stack.pop()
		p.status_stack.pop()
		p.status = p.status_stack.pop()

		dest := p.dest_stack.peek()
		dest.Set(reflect.Append(dest, obj))

	case "control":

		if t.value == ":" {
			return fmt.Errorf("invalid json: unexpected :")
		}

		p.key_stack.pop()
		p.status = p.status_stack.pop()

	case "start":
		if t.value == "object" {
			p.status_stack.push(p.status)
			p.status = parse_object
			return nil
		}

		if t.value == "array" {
			p.status_stack.push(p.status)
			p.status = parse_array

			key := p.key_stack.peek()
			dest := p.dest_stack.peek()
			field := dest.FieldByName(key)

			if field.Kind() != reflect.Slice {
				return fmt.Errorf("invalid parser status, must be in a slice to read an array")
			}

			p.dest_stack.push(field)
			return nil
		}

	case "float":
		key := p.key_stack.peek()
		dest := p.dest_stack.peek()
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
