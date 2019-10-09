extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(g.NEEDS_DEVICE_CLICK)
	
func on_device_click(device:Device):
	$device_name.text = device.device_type

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
