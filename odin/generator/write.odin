package generator

import "core:encoding/json"
import "core:io"
import "core:strconv"

write_f64_exact :: proc(w: io.Writer, v: any, opt: ^json.Marshal_Options) -> json.Marshal_Error {
	buf: [386]byte
	str := strconv.write_float(buf[1:], v.(f64), 'f', -1, 64)
	s := buf[:len(str) + 1]
	if s[1] == '+' || s[1] == '-' {
		s = s[1:]
	} else {
		s[0] = '+'
	}
	if s[0] == '+' {
		s = s[1:]
	}
	io.write_string(w, string(s)) or_return
	return nil
}
