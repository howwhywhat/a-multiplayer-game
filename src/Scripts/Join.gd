extends Button

signal set_connect_type

func join():
	Network.initialize_client($IP.text)
	emit_signal("set_connect_type", false)

func _pressed():
	if $IP.text.is_valid_ip_address():
		$InvalidIP.hide()
		join()
	else:
		$InvalidIP.show()
