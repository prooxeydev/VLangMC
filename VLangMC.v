module main

import net
import io

fn main() {
	port := 4088
	mut state := State.Handshake
	socket := net.listen(port) or { panic(err) }

	for {
		client := socket.accept() or { panic(err) }

		handshake_pkt := read_packet(state, client)
		reader := create_buf_reader()
		reader.set_buffer(handshake_pkt.data)

		protocol_ver := reader.read_pure_var_int() or { panic(err) }
		server_address := reader.read_string(10)
		port := reader.read_short(4)
		next_state := reader.read_pure_var_int() or { panic(err) }

	}

	socket.close() or { panic(err) }
}