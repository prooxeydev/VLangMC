module packets

//import json
import net
/*
pub struct StatusResponse {
	version Version
	players Players
	description Description
	favicon string
}

struct Version {
	name string
	protocol int
}

struct Players {
	max int
	online int
	sample []PlayerData
}

struct PlayerData {
	name string
	uuid string
}

struct Description {
	text string
}

pub fn create_status_response(version string, protocol int, max_player int, online_player int, players []PlayerData, description string, favicon string) StatusResponse {
	return StatusResponse{
		version: Version{version, protocol}
		players: Players{max_player, online_player, players}
		description: Description{description}
		favicon: favicon
	}
}

pub fn decode_status_response(response string) ?StatusResponse {
	resp := json.decode(StatusResponse, response) or { return error('Cannot decode response, err: $err') }
	return resp
}

pub fn encode_status_respone(StatusResponse response) string {
	data := json.encode(response)
	return data
}
*/
pub fn read_packet_len(sock net.Socket) ?int {
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

pub fn create_status_response() string {
	data := '{"version":{"name":"1.15.2","protocol": 578},"players": {"max": 100,"online": 5,"sample": [{"name": "thinkofdeath","id": "4566e69f-c907-48ee-8d71-d7ba5aa00d20"}]},"description": {"text": "Hello world"},"favicon": "data:image/png;base64,<data>"}'
	return data.trim_space()
}