package json

type stack struct {
	data  []rune
	index int
}

func newStack() stack {
	return stack{
		data:  nil,
		index: -1,
	}
}

func (s *stack) Push(r rune) {
	s.data = append(s.data, r)
	s.index++
}

func (s *stack) Pop() rune {
	if len(s.data) == 0 {
		return 0
	}

	r := s.data[s.index]
	s.index--
	return r
}
