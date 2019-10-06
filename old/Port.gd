extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var color = Color.green
var radius = 8
var active_connection = null

var Connection = preload("res://Connection.tscn")

enum {IDLE, CONNECT, RECEIVE}

var state = IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(g.PORT)
	self.global_position = g.ridify(self.global_position)
	
	

func has_mouse_over():
	var mp = get_local_mouse_position()
	return mp.length() < radius


func start_connection():
	var c = Connection.instance()
	add_child(c)
	
func _input(event):
	if has_mouse_over():
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			if event.pressed:
				g.on_port_clicked(self)


func _process(delta):
	update()


func _draw():
	if has_mouse_over():
		draw_circle(Vector2.ZERO, radius, Color.yellow)
	else:
		draw_circle(Vector2.ZERO, radius, Color.green)