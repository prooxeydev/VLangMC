module main

pub fn create_response_string() string {
	return '{
    "version": {
        "name": "1.15.2",
        "protocol": 587
    },
    "players": {
        "max": 100,
        "online": 5,
        "sample": [
            {
                "name": "thinkofdeath",
                "id": "4566e69f-c907-48ee-8d71-d7ba5aa00d20"
            }
        ]
    },	
    "description": {
        "text": "Hello world"
    },
    "favicon": ""
}'
}