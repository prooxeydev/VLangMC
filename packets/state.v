module packets

pub enum State {
	Handeshake,
	Status,
	Ping,
	Play
}

type state = State