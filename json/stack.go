package json

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
	s.data = append(s.data, v)
	s.index++
}

func (s *stack[T]) pop() T {
	if len(s.data) == 0 {
		return *new(T)
	}

	v := s.data[s.index]
	s.index--
	return v
}

func (s *stack[T]) peek() (v T) {
	if len(s.data) == 0 {
		return
	}

	return s.data[s.index]
}
