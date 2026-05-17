package json

type token struct {
	token_type string
	value      string
}

var object_start = token{
	token_type: "object",
	value:      "start",
}

var object_end = token{
	token_type: "object",
	value:      "end",
}

var array_start = token{
	token_type: "array",
	value:      "start",
}

var array_end = token{
	token_type: "array",
	value:      "end",
}

var comma = token{
	token_type: "control",
	value:      ",",
}

var colon = token{
	token_type: "control",
	value:      ":",
}
