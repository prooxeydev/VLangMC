module packets

const (
	HANDSHAKE = 0
	STATUS = 1
	LOGIN = 2
	PLAY = 3
)

enum State {
	Handshake
	Status
	Login
	Play
}