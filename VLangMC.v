module main

import net

fn main() {
	port := 4088
	socket := net.listen(port) or { panic(err) }

	for {
		client := socket.accept() or { panic(err) }

		len := read_var_int(client) or { panic(err) }
		id := read_var_int(client) or { panic(err) }
		w_id := id.hex()
		protocol_ver := read_var_int(client) or { panic(err) }
		host_len := len - id.str().len - protocol_ver.str().len - port.str().len + 2
		host := read_string(client, host_len)
		port_r := read_u_short(client, port.str().len)
		next_state := read_var_int(client) or { panic(err) }

		request_len := read_var_int(client) or { panic(err) }
		request_id := read_var_int(client) or { panic(err) }
		w_requst_id := request_id.hex()

		println('Request with len:$request_len with id 0x$w_requst_id')

		response := create_response_string()
		mut response_len := response.len

		response_len = write_var_int(len)

		println(response_len)

		//client.send(byte(response_len), response_len.bytes().len)
		
		ping_len := read_var_int(client) or { panic(err) }
		ping_id := read_var_int(client) or { panic(err) }
		w_ping_id := ping_id.hex()

		println('Request with len:$ping_len with id 0x$w_ping_id')

		//payload := read_long(client, ping_len)
	
	}

	socket.close() or { panic(err) }
}