module openconnection

import net
import packets
import io

pub fn start(port int, state packets.State, client net.Socket) {
	println('state: $state')
	if state == packets.State.Handshake {
		s := handshake(port, state, client)
		start(port, s, client)
	} else if state == packets.State.Status {
		request := receive_request(state, client)

		println('received request')

		if request == 0 {
			send_response(client)
		}

		println('send response')

		ping := receive_ping(state, client)
		send_pong(ping, client)
	}
}

fn handshake(port int, state packets.State, client net.Socket) int {
	_, mut reader := packets.read_packet(state, client) or { panic(err) }

	protocol_ver := reader.read_pure_var_int() or { panic(err) }
	server_address := reader.read_string()
	server_port := reader.read_short(4)
	next_state := reader.read_var_int_enum()

	println(server_address.len)
	println('protocol: $protocol_ver')
	println('host: $server_address')
	println('port: $server_port')
	println('next_s: $next_state')

	return next_state
}

fn receive_request(state packets.State, client net.Socket) int {
	request_pkt, _ := packets.read_packet(state, client) or { panic(err) }
	if request_pkt.packet_id == 0 && request_pkt.len == 1 {
		return 0
	} else {
		return -1
	}
}

fn send_response(client net.Socket) {
	json := packets.create_status_response()
	writer := io.create_buf_writer()
	writer.create_empty()
	writer.write_string(json)

	buf := writer.flush(0)
	
	for data in buf {
		client.send(data, 1) or { panic(err) }
	}
} 

fn receive_ping(state int, client net.Socket) int {
	ping_pkt, reader := packets.read_packet(state, client) or { panic(err) }
	payload := reader.read_long(ping_pkt.len - ping_pkt.packet_id.str().len)
	return payload
}

fn send_pong(pong u64, client net.Socket) {
	writer := io.create_buf_writer()
	writer.create_empty()
	writer.write_u_long(pong)

	buf := writer.flush(1)

	for data in buf {
		client.send(data, 1) or { panic(err) }
	}
}