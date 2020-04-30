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

		println('received ping')

		if ping == 0 {
			
		}
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
	json_len := json.len
	writer := io.create_buf_writer()
	writer.create_empty()
	writer.write_var_int(json_len)
	writer.write_string(json)
	buf_len, packet_data, buf := writer.flush(0)

	mut b := []byte{}
	b << buf_len
	b << packet_data
	b << buf

	reader := io.create_buf_reader()
	reader.set_buffer(b)

	len := reader.read_pure_var_int() or { panic(err) }
	packet_id := reader.read_pure_var_int() or { panic(err) }
	json_len_i := reader.read_pure_var_int() or { panic(err) }

	println('Packet len: $len')
	println('Packet id: $packet_id')
	println('json len: $json_len_i')

	//client.send(buf_len, buf_len.len) or { panic(err) }
	//client.send(packet_data, packet_data.len) or { panic(err) }
	//client.send(buf, buf.len) or { panic(err) }
} 

fn receive_ping(state int, client net.Socket) int {
	ping_pkt, _ := packets.read_packet(state, client) or { panic(err) }
	println('ping_packet: $ping_pkt')
	return 0
}