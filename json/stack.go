package json

import "fmt"

type stack[T any] struct {
	data  []T
	index int
}

func newStack[T any]() stack[T] {
	return stack[T]{
		data:  nil,
		index: -1,
	}
}

func (s *stack[T]) push(v T) {
	idx := s.index + 1

	if idx >= len(s.data) {
		s.data = append(s.data, v)
	} else {
		s.data[idx] = v
	}

	s.index++
}

func (s *stack[T]) pop() (v T) {
	if len(s.data) == 0 {
		return
	}

	v = s.data[s.index]
	s.index--
	return v
}

func (s *stack[T]) peek() (v T) {
	if len(s.data) == 0 {
		return
	}

	return s.data[s.index]
}

func (s stack[T]) String() string {
	return fmt.Sprintf("%v", s.data[:s.index+1])
}
