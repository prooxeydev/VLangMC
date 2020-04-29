module io

import encoding.binary

pub struct BufferWriter {
mut:
	buf []byte
}

pub fn create_buf_writer() BufferWriter {
	return BufferWriter{}
}

pub fn (writer mut BufferWriter) create_empty() {
	writer.buf = []byte{}
}

pub fn (writer mut BufferWriter) set_buffer(buf []byte) {
	writer.buf = buf
}

pub fn (writer mut BufferWriter) write_var_int(val int) {
	mut v := val
	for {
		if (v & 128) == 0 {
			break
		}
		writer.buf << (v & 127 | 128)
		v >>= 7
	}
	writer.buf << v
}

pub fn (writer mut BufferWriter) write_byte(val byte) {
	writer.buf << val
}

pub fn (writer mut BufferWriter) write_string(str string) {
	buf := str.bytes()
	writer.write_var_int(buf.len)
	writer.buf << buf
}

pub fn (writer mut BufferWriter) flush(id int) ([]byte, []byte, []byte) {
	mut buf := writer.buf.clone()
	writer.buf = []byte{}

	mut add := 0
	mut packet_data := [ byte(0x00) ]
	if id >= 0 {
		writer.write_var_int(id)
		packet_data = writer.buf.clone()
		writer.buf = []byte{}
		add = packet_data.len
	}

	writer.write_var_int(buf.len + add)
	buf_len := writer.buf.clone()
	writer.buf = []byte{}

	return buf_len, packet_data, buf
}

/*pub fn (writer mut BufferWriter) write_short(short u16) {
	mut data := []byte{}
	binary.big_endian_put_u16(data, short)
	writer.buf << data
}

pub fn (writer mut BufferWriter) write_long(long u64) {
	mut data := []byte{}
	binary.big_endian_put_u64(data, long)
	writer.buf << data
}*/