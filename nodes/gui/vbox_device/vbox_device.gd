extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var port_gui = preload("res://nodes/gui/port/port.tscn")

var current_device:Device
# Called when the node enters the scene tree for the first time.
onready var device_name = $desc/device_name
onready var ports = $ports


func _ready():
	add_to_group(g.NEEDS_DEVICE_CLICK)
	
func on_device_click(device:Device):
	if current_device != device:
		current_device = device
		update_gui()
	
	
func update_gui():
	device_name.text = current_device.device_type
	
	for child in ports.get_children():
		child.queue_free()
		
	for port in current_device.ports.get_children():
		var p = port_gui.instance()
		ports.add_child(p)
		p.port_name.text = port.name
		if port.connected_port:
			p.port_name.text += "->" + port.connected_port.device.name
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
