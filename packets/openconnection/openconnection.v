module openconnection

import net
import packets
import io

pub fn start(port int, state int, client net.Socket) {
	match handshake(port, state, client) {
		1 {
			if receive_request(state, client) == 0 {
				send_response(client)
				if receive_ping(state, client) == 0 {

				}
			}
		}
		2 {

		}
		else {
			return
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
	println(buf.len)
	//client.send(buf, buf.len) or { panic(err) }
}

fn receive_ping(state int, client net.Socket) int {
	ping_pkt, _ := packets.read_packet(state, client) or { panic(err) }
	println(ping_pkt)
	return 0
}