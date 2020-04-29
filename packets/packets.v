module packets

import net

pub struct Packet {
pub:
	ac_state state
	packet_id int
pub mut:
	data []byte
}

pub fn read_packet(ac_state state, sock net.Socket) ?Packet {
	len := read_packet_len(sock) or { return error('PacketLength cannot be read') }
	reader := create_buf_reader()
	buf, _ := sock.recv(len)
	reader.set_buffer(buf)
	packet := read_packet_data(len, state, reader)
	return packet
}
 
fn read_packet_data(len int, ac_state state, reader Reader) Packet {
	mut ln := len
	pack_id, id_len := reader.read_var_int()
	ln -= id_len
	data := reader.read(ln)
	return Packet{ac_state, pack_id, data}
}
