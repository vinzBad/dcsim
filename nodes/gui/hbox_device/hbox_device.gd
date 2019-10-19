extends HBoxContainer

var _device:Device = null
var _port:Port = null

onready var hostname = $values/hostname
onready var portname = $values/port
onready var updown = $labels/down

func set_device(device:Device):
	_device = device
	if device:
		hostname.text = device.hostname

func set_port(port:Port):
	_port = port
	if port:
		portname.text = port.port_name
		
	update_button_labels()

func update_button_labels():
	if _port and _port.connected_port:
		updown.disabled = false
		updown.text = "down"
		updown.hint_tooltip = "disable port"
	elif _port and _port.connection and !_port.connected_port:
		updown.disabled = false
		updown.text = "up"
		updown.hint_tooltip = "enable port"


func _on_poweroff_pressed():
	pass # Replace with function body.


func _on_down_pressed():
	if !_port:
		return
	if _port.connected_port:
		_port.connected_port = null
	elif _port.connection:
		if _port.connection.port_start == _port:
			_port.connected_port = _port.connection.port_end
		else:
			_port.connected_port = _port.connection.port_start
			
	update_button_labels()

func _on_remove_pressed():
	pass # Replace with function body.


func _on_disconnect_pressed():
	pass # Replace with function body.
