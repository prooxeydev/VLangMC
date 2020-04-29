module io

import net
import encoding.binary

pub struct BufferReader {
mut:
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
	copy(data, reader)
	data = data.slice(reader.offset, reader.offset + len)
	reader.offset += len
	return data
}

pub fn (reader mut BufferReader) read_pure_var_int() ?int {
	mut value := 0
	mut size := 0
	for {
		b := reader.read_byte()
		if (b & 0x80) != 0x80 {
			break
		}
		value |= (b & 0x7F) << (size++ * 7)
		if size > 5 {
			return error('VarInt is too big!')
		}
	}
	return value | ((b & 0x7F) << (size * 7)
}

pub fn (reader mut BufferReader) read_var_int() ?(int, int) {
	mut value := 0
	mut size := 0
	for {
		b := reader.read_byte()
		if (b & 0x80) != 0x80 {
			break
		}
		value |= (b & 0x7F) << (size++ * 7)
		if size > 5 {
			return error('VarInt is too big!')
		}
	}
	return (value | ((b & 0x7F) << (size * 7), size)
}

pub fn (reader mut BufferReader) read_string(len int){
	data := reader.read(len)
	return string(data).ustring()
}

pub fn (reader mut BufferReader) read_u_short(len int) u16 {
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
		result << buffer[0]
	}

	return binary.big_endian_u64(result)
}

pub fn (reader mut BufferReader) read_var_int_enum() int {
	result := reader.read_var_int() or { panic(err) }
	return result.str().len
}