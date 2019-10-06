tool
class_name Device
extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var width = 6 * 24
export var height = 2 * 24
export var color = Color.green
export var device_type = "DEVICE"

onready var uid = g.get_uid()

# Called when the node enters the scene tree for the first time.
func _ready():
	g.uid2device[uid] = self
	
func start():
	g.packet_nav.add_point(uid, Vector3(global_position.x, global_position.y, 0))
	add_to_group(device_type)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	draw_rect(Rect2(Vector2.ZERO, Vector2(width, height)), color, false)
	for p in [Vector2.ZERO, Vector2(0, height), Vector2(width, 0), Vector2(width, height)]:
		draw_circle(p, 4, color)

func get_port_to_uid(uid):
	for port in $ports.get_children():
		if port.connected_port:
			if port.connected_port.device.uid == uid:
				return port
	return null

func port_up(my_port, other_port):
	g.packet_nav.connect_points(uid, other_port.device.uid)

func port_down(my_port, other_port):
	if other_port != null:
		g.packet_nav.disconnect_points(uid, other_port.device.uid)

func save():
	var data = {
		"ports":[],
		"services":[]
	}
	
	return data

func load(data):
	start()
	