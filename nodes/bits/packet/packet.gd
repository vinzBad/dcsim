extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var width = 14
var height = 14
var color = Color.blue
var thickness = 3

var source:Device = null
var destination = null




var path = null
var path_index = 0
var next_point = Vector2.ZERO
var next_points = []
var next_points_distances = []
var full_distance = 0
var current_distance = 0
var distance_per_second = 0
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
	next_points_index = 0
	next_points = [next_device.global_position]
	return
	var start_port = current_device.get_port_to_uid(next_device.uid)
	if start_port == null:
		queue_free()
		return
		
	var connection = start_port._conn
	self.global_position = start_port.global_position
	next_points_index = 0
	self.next_points.clear()
	self.next_points = connection.points.duplicate()
	if start_port == connection.port_end:
		self.next_points.invert()
		
	for i in range(len(next_points)):
		next_points[i] = connection.to_global(next_points[i])
		
	
	
		


func _ready():
	add_to_group(g.PACKET)
	add_to_group(g.NEED_UPDATE_COLORSCHEME)
	set_process(false)

func next(speed):
	var current_device = g.uid2device[path[path_index]]	
	
	if current_device == destination:
		g.money += 1.2
		set_process(false)
		queue_free()
		return
		
	
	if current_device is Device:
		path_index += 1	
		next(speed)		
		return
		
	if current_device is Port and g.uid2device[path[path_index-1]] is Port:
		path_index += 1
		next(speed)
		return
	
	path_index += 1	
	
	set_process(true)
	var start_port = current_device
	if not is_instance_valid(current_device):
		queue_free()
		set_process(false)
		return
		
	var connection = current_device._conn
	if connection == null:
		queue_free()
		set_process(false)
		return
	if current_device.other_port() == null:
		queue_free()
		set_process(false)
		return
	self.global_position = start_port.global_position
	next_points_index = 0
	
	self.next_points.clear()
	self.next_points_distances.clear()
	self.full_distance = 0
	self.current_distance = 0
	
	self.next_points = connection.points.duplicate()
	if start_port == connection.port_end:
		self.next_points.invert()
	

	for i in range(len(next_points)):	
		next_points[i] = connection.to_global(next_points[i])
		if i >= 1:			
			var distance =  (next_points[i-1] - next_points[i]).length()
			full_distance += distance
			next_points_distances.append(full_distance)
		else:
			next_points_distances.append(0)
			
	distance_per_second = full_distance / speed
	
	self.global_position = current_device.global_position
	self.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.

func get_current_index():
	for i in range(1, len(next_points_distances)):
		if current_distance > next_points_distances[i-1] and current_distance <= next_points_distances[i]:
			return i-1
	return len(next_points) -1
	
func _process(delta):
#	distance_per_second = 400
	current_distance += distance_per_second * delta
	if current_distance >= full_distance:
		self.visible = false
	current_distance = clamp(current_distance, 0, full_distance)
	var i = get_current_index()
	var d = (next_points[i+1] - next_points[i]).normalized()
	d *= current_distance - next_points_distances[i]
	self.global_position = next_points[i] + d
	
	
#	return
#	next_point = next_points[next_points_index]
#	var d:Vector2 = (next_point - self.global_position)
#
#	if d.length() < 4:
#		next_points_index += 1
#		if next_points_index >= len(next_points):
#			path_index += 1
#			fill_next()
#	else:
#		self.global_position += d.normalized() * 100 * delta
	

func _draw():
	color = Color(g.colorscheme["packet"])
	draw_colored_polygon(
	[Vector2(-width/2, 0), Vector2(0, height/2),Vector2(width/2, 0), Vector2(0, -height/2)],
	color)
	