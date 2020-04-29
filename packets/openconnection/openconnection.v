module openconnection

import net
import packets
import io

pub fn start(port int, state int, client net.Socket) {
	println(state)
	if state == packets.HANDSHAKE {
		s := handshake(port, state, client)
		start(port, s, client)
	} else if state == packets.STATUS {
		request := receive_request(state, client)

		if request == 0 {
			send_response(client)
		}

		ping := receive_ping(state, client)

		if ping == 0 {
			
		}
	}
}

fn handshake(port int, state int, client net.Socket) int {
	handshake_pkt, mut reader := packets.read_packet(state, client) or { panic(err) }

	protocol_ver := reader.read_pure_var_int() or { panic(err) }
	reader.offset++
	address_len := handshake_pkt.len - handshake_pkt.packet_id.str().len - protocol_ver.str().len - port.str().len + 1
	server_address := reader.read_string(address_len)
	server_port := reader.read_short(4)
	next_state := reader.read_var_int_enum()

	println('protocol: $protocol_ver')
	println('host: $server_address')
	println('port: $server_port')
	println('next_s: $next_state')

	return next_state
}

fn receive_request(state int, client net.Socket) int {
	request_pkt, _ := packets.read_packet(state, client) or { panic(err) }
	println(request_pkt.packet_id)
	if request_pkt.packet_id == 0 && request_pkt.len == 1 {
		return 0
	} else {
		return -1
	}
}

fn send_response(client net.Socket) {
	json := packets.create_status_response()
	json_len := json.len
	writer := io.create_buf_writer()
	writer.create_empty()
	writer.write_var_int(json_len)
	writer.write_string(json)
	buf := writer.flush(0)
	client.send(buf, buf.len) or { panic(err) }
}

fn receive_ping(state int, client net.Socket) int {
	ping_pkt, _ := packets.read_packet(state, client) or { panic(err) }
	println('ping $ping_pkt')
	return 0
}