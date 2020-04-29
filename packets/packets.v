module packets

import net
import io

pub struct Packet {
pub:
	state int
	len int
	packet_id int
pub mut:
	data []byte
}

pub fn read_packet(state int, sock net.Socket) ?(Packet, io.BufferReader) {
	len := read_packet_len(sock) or { return error('PacketLength cannot be read') }
	if len <= 0 { return error('PacketLength is 0') }
	reader := io.create_buf_reader()
	buf, _ := sock.recv(len)
	reader.set_buffer(buf)
	packet := read_packet_data(len, state, &reader) or { return error(err) }
	return packet, reader
}
 
fn read_packet_data(len int, state int, reader &io.BufferReader) ?Packet {
	pack_id := reader.read_pure_var_int() or { return error('PacketID cannot be read') }
	return Packet{
		state: state
		len: len
		packet_id: pack_id
		data: string(reader.buf).bytes()
		}
}
