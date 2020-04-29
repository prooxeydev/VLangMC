module io

import net
import encoding.binary

pub struct BufferReader {
pub mut:
	buf byteptr
	offset int
}

pub fn create_buf_reader() BufferReader {
	return BufferReader{}
}

pub fn (reader mut BufferReader) set_buffer(buf byteptr) {
	reader.offset = 0
	reader.buf = buf
}

pub fn (reader mut BufferReader) read_byte() byte {
	b := reader.buf[reader.offset]
	reader.offset++
	return b
}

pub fn (reader mut BufferReader) read(len int) []byte {
	mut data := []byte{}
	
	for i := 0; i < len; i++ {
		data << reader.read_byte()
	}

	return data
}

pub fn (reader mut BufferReader) read_pure_var_int() ?int {
	mut value := 0
	mut size := 0
	mut b := byte(0)
	for {
		b = reader.read_byte()
		if (b & 0x80) != 0x80 {
			break
		}
		value |= (b & 0x7F) << (size++ * 7)
		if size > 5 {
			return error('VarInt is too big!')
		}
	}
	return value | (b & 0x7F) << (size * 7)
}

pub fn (reader mut BufferReader) read_var_int() ?(int, int) {
	mut value := 0
	mut size := 0
	mut b := byte(0)
	for {
		b = reader.read_byte()
		if (b & 0x80) != 0x80 {
			break
		}
		value |= (b & 0x7F) << (size++ * 7)
		if size > 5 {
			return error('VarInt is too big!')
		}
	}
	result := value | (b & 0x7F) << (size * 7)
	return result, size
}

fn convert_byte(b byte) byte {
	return (b & 0b01111111)
}

pub fn (reader mut BufferReader) read_string(len int) string {
	mut data := []byte{}

	for b in reader.read(len) {
		conv := convert_byte(b)
		data << conv
	}

	return string(data)
}

pub fn (reader mut BufferReader) read_short(len int) u16 {
	mut result := []byte{}
	
	for i := 0; i < len; i++ {
		b := reader.read_byte()
		result << b
	}

	return binary.big_endian_u16(result)
}

pub fn (reader mut BufferReader) read_long(len int) u64 {
	mut result := []byte{}
	
	for i := 0; i < len; i++ {
		b := reader.read_byte()
		result << b
	}

	return binary.big_endian_u64(result)
}

pub fn (reader mut BufferReader) read_var_int_enum() int {
	a, _ := reader.read_var_int() or { panic(err) }
	return a.str().len
}