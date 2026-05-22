package stack

import "fmt"

type Stack[T any] struct {
	data  []T
	index int
}

func New[T any]() Stack[T] {
	return Stack[T]{
		data:  nil,
		index: -1,
	}
}

func (s *Stack[T]) Push(v T) {
	idx := s.index + 1

	if idx >= len(s.data) {
		s.data = append(s.data, v)
	} else {
		s.data[idx] = v
	}

	s.index++
}

func (s *Stack[T]) Pop() (v T) {
	if len(s.data) == 0 {
		return
	}

	v = s.data[s.index]
	s.index--
	return v
}

func (s *Stack[T]) Peek() (v T) {
	if len(s.data) == 0 {
		return
	}

	return s.data[s.index]
}

func (s Stack[T]) String() string {
	return fmt.Sprintf("%v", s.data[:s.index+1])
}
