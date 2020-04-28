module main

import net

pub fn write_var_int(val int) byte {
	mut tmp_buf := []byte{}
	mut tmp_val := val
	for {
		if (tmp_val & 128) == 0 {
			break
		}
		tmp_buf << (tmp_val & 127 | 128)
		tmp_val = tmp_val >> 7
	}
	return tmp_val
}