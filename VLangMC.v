module main

import net
import packets.openconnection
import packets

fn main() {
	port := 4088
	mut state := packets.HANDSHAKE
	socket := net.listen(port) or { panic(err) }

	for {
		client := socket.accept() or { panic(err) }
		openconnection.start(port, state, client)
	}

	socket.close() or { panic(err) }
}