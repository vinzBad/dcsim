extends HBoxContainer

var _device:Device = null
var _port:Port = null

onready var hostname = $values/hostname
onready var portname = $values/port
onready var portstate = $values/port_state
onready var disable = $labels/disable

func _ready():
	md.connect_message(g.RESET, self, "reset")
	
func reset(t, msg):
	set_device(null)
	set_port(null)
	update_button_labels()
	
func set_device(device:Device):
	_device = device
	hostname.text = ""
	if device:
		hostname.text = device.hostname
	update_button_labels()

func set_port(port:Port):
	_port = port
	portname.text = ""
	portstate.text = ""
	if port:
		portname.text = port.port_name		
	update_button_labels()

func update_button_labels():
	if _port:
		portname.text = _port.port_name
		portstate.text = _port.state_as_string()
		if _port.state == Port.DISABLED:
			disable.text = "enable"
			disable.hint_tooltip = "enable port"
		else:
			disable.text = "disable"
			disable.hint_tooltip = "disable port"

	hide()
	show()
func _on_poweroff_pressed():
	pass # Replace with function body.


func _on_down_pressed():
	if !_port:
		return
	if _port.state == Port.DISABLED:
		_port.enable()
	else:
		_port.disable()
			
	update_button_labels()

func _on_remove_pressed():
	pass # Replace with function body.


func _on_disconnect_pressed():
	pass # Replace with function body.
