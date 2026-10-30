package bson

ControlToken :: enum {
	Array_Start,
	Array_End,
	Comma,
	Colon,
	Object_Start,
	Object_End,
}

Error :: enum {
	nil,
	Dest_Not_Pointer,
	EmptyDestStack,
	Expected_Control_Token,
	Invalid_Control_Token,
	Invalid_Float,
	Invalid_Int,
	Invalid_String,
	Unexpected_Colon,
	Unexpected_Comma,
	Unexpected_End_Of_Array,
	Unexpected_End_Of_Object,
	Unexpected_Rune,
}

Lexer :: struct {
	Status: LexerStatus,
	Buffer: [dynamic]rune,
	Tokens: [dynamic]Token,
}

LexerStatus :: enum {
	Normal,
	Int,
	Float,
	String,
}

Parser :: struct {
	status:       ParserStatus,
	dest:         any,
	key:          string,
	dest_stack:   [dynamic]any,
	key_stack:    [dynamic]string,
	status_stack: [dynamic]ParserStatus,
}

ParserStatus :: enum {
	Value,
	Array,
	String,
}

Token :: union {
	ControlToken,
	int,
	f64,
	string,
}
