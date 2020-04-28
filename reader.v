module main

import net
import encoding.binary

pub struct Reader {
	
}

pub fn read_var_int(sock net.Socket) ?int {
	mut num_read := 0
	mut result := 0
	mut read := byte(0)

	for {
		buffer, _ := sock.recv(1)
		read = buffer[0]
		value := (read & 0b01111111)
		result |= (value << (7 * num_read))

		num_read++
		if num_read > 5 {
			return error('VarInt is too long!')
		}
		if (read & 0b10000000) == 0 {
			break
		}
	}
	return result
}

fn read_single(sock net.Socket) byte {
	buffer, _ := sock.recv(1)
	read := buffer[0]
	value := (read & 0b01111111)
	return value
}

pub fn read_string(sock net.Socket, len int) string {
	mut result := []byte{}
	
	for i := 0; i < len; i++ {
		result << read_single(sock)
	}

	return string(result)
}

pub fn read_u_short(sock net.Socket, len int) u16 {
	mut result := []byte{}
	
	for i := 0; i < len; i++ {
		buffer, _ := sock.recv(1)
		result << buffer[0]
	}

	return binary.big_endian_u16(result)
}


pub fn read_long(sock net.Socket, len int) u64 {
	mut result := []byte{}
	
	for i := 0; i < len; i++ {
		buffer, _ := sock.recv(1)
		result << buffer[0]
	}

	return binary.big_endian_u64(result)
}

pub fn read_var_int_enum(sock net.Socket) int {
	result := read_var_int(sock) or { panic(err) }
	return result.str().len
}