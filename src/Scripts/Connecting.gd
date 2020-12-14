extends Label

const CONNECT_TEXT = ["Waiting for players", "Connecting"]

func set_connect_type(host):
	show()
	if host:
		text = CONNECT_TEXT[0]
	else:
		text = CONNECT_TEXT[1]
