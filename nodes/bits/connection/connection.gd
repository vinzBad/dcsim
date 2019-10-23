extends Node2D
class_name Connection
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var points = [Vector2.ZERO]
var next_points = []
var color = Color.green
var current_index = 0
var is_active = false

var port_start = null
var port_end = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(g.NEED_UPDATE_COLORSCHEME)
	
func start(port:Node2D):
	self.global_position = port.global_position
	is_active = true
	port_start = port
	port.set_conn(self)

func finish(port:Node2D):
	compute_next_points(to_local(port.global_position))
	commit_next_points()
	update()
	is_active = false
	port_end = port
	port.set_conn(self)
	

func other_port(port):
	assert(port != null)
	assert(port == port_start or port == port_end)
	if port == port_start:
		return port_end
	else:
		return port_start
	
func remove():
	if port_start:
		port_start.remove_conn()
	if port_end:
		port_end.remove_conn()
	queue_free()
	

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			commit_next_points()

func commit_next_points():
	for p in next_points:
		points.append(p)
	next_points.clear()

func compute_next_points(target:Vector2):
	var lp = points.back()
	
	var d = lp - target
	
	if d.x == 0 or d.y == 0:
		next_points = [g.ridify(target, lp)]
	elif abs(d.x) < abs(d.y):
		var np = g.ridify(Vector2(lp.x, target.y), lp)
		next_points = [np, g.ridify(target, np)]
	else:
		var np = g.ridify(Vector2(target.x, lp.y), lp)
		next_points = [np, g.ridify(target, np)]

func _process(delta):
	if is_active:
		compute_next_points(get_local_mouse_position())
		update()

func _draw():
	var color = Color(g.colorscheme["connection"])
	var lp = Vector2.ZERO
	#draw_circle(lp, 4, color)
	for p in points:
		draw_line(lp, p, color, 2)
		lp = p
#	if !is_active:
#		draw_circle(lp, 4, color)
	for p in next_points:
		draw_line(lp, p, color)
		lp = p
		
func save():
	if is_active:
		return {}
	
	var data = {
		"points":[],
		"port_start": {
			"hostname": port_start.device.hostname,
			"port_name": port_start.port_name
		},
		"port_end": {
			"hostname": port_end.device.hostname,
			"port_name": port_end.port_name
		}
	}
	for p in points:
		data["points"].append({"pos_x":p.x, "pos_y":p.y})
	return data
	
func load_from_save(data:Dictionary):
	if data.empty():
		queue_free()		
	points.clear()
	
	for p in data["points"]:
		points.append(Vector2(p["pos_x"], p["pos_y"]))
		
	port_start = g.find_port(data["port_start"]["hostname"], data["port_start"]["port_name"])
	port_end = g.find_port(data["port_end"]["hostname"], data["port_end"]["port_name"])
	
	port_end._conn = self
	port_start.set_conn(self)