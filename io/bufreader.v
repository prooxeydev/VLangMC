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

pub fn (reader mut BufferReader) read_var(max int) i64 {
	mut value := i64(0)
	mut size := 0
	for {
		b := reader.read_byte()

		value |= (b & 0x7F) << (size++ * 7)
		if size > max {
			return 0
		}
		if (b & 0x80) != 0x80 {
			break
		}
	}
	return value
}

pub fn (reader mut BufferReader) read_string() string {
	mut data := []byte{}
	len := reader.read_pure_var_int() or { panic(err) }
	data << reader.read(len)

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

pub fn (reader mut BufferReader) read_long() i64 {
	return i64(binary.big_endian_u64(reader.read(8)))
}

pub fn (reader mut BufferReader) read_var_int_enum() int {
	a, _ := reader.read_var_int() or { panic(err) }
	return a.str().len
}