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
	Invalid_Dest,
	Invalid_String,
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

Token :: union {
	ControlToken,
	int,
	f64,
	string,
}
