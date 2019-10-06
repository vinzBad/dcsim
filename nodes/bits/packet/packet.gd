tool
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var width = 16
var height = 16
var color = Color.blue
var thickness = 3

var source:Device = null
var destination:Device = null




var path = null
var path_index = 0
var next_point = Vector2.ZERO
var next_points = []
var next_points_index = 0


func start(src, dest):
	source = src
	destination = dest
	self.global_position = src.global_position
	path = g.packet_nav.get_id_path(src.uid, dest.uid)
	path_index = 0
	
	if len(path) == 0:
		queue_free()
		self.set_process(false)
	else:
		fill_next()

func fill_next():	
	var current_device = g.uid2device[path[path_index]]
	if current_device == destination:
		queue_free()
		return
	
	var next_device =  g.uid2device[path[path_index+1]]
	var start_port = current_device.get_port_to_uid(next_device.uid)
	var connection = start_port.connection
	self.global_position = start_port.global_position
	next_points_index = 0
	self.next_points.clear()
	self.next_points = connection.points.duplicate()
	if start_port == connection.port_end:
		self.next_points.invert()
		
	for i in range(len(next_points)):
		next_points[i] = connection.to_global(next_points[i])
		
	
	
		


func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	next_point = next_points[next_points_index]
	var d:Vector2 = (next_point - self.global_position)
	
	if d.length() < 4:
		next_points_index += 1
		if next_points_index >= len(next_points):
			path_index += 1
			fill_next()
	else:
		self.global_position += d.normalized() * 100 * delta
	

func _draw():
	draw_line(Vector2(-width/2, 0), Vector2(0, -height/2), color, thickness, true)
	draw_line(Vector2(-width/2, 0), Vector2(0, height/2), color, thickness, true)
	draw_line(Vector2(width/2, 0), Vector2(0, -height/2), color, thickness, true)
	draw_line(Vector2(width/2, 0), Vector2(0, height/2), color, thickness, true)