package json

type token struct {
	kind  string
	value string
}

var object_start = token{
	kind:  "start",
	value: "object",
}

var object_end = token{
	kind:  "end",
	value: "object",
}

var array_start = token{
	kind:  "start",
	value: "array",
}

var array_end = token{
	kind:  "end",
	value: "array",
}

var comma = token{
	kind:  "control",
	value: ",",
}

var colon = token{
	kind:  "control",
	value: ":",
}
