extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var active_connection = null
var active_device = null

var left_pressed = false

onready var world = $world

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(g.NEEDS_PORT_CLICK)

func on_port_click(port:Node2D):
	if port.connected_port:
		remove_connection(port.connection)
			
	if active_connection:
		if active_connection.port_start == port:
			return
			
		port.connected_port = active_connection.port_start
		active_connection.port_start.connected_port = port
		port.connection = active_connection
		active_connection.finish(port)
		active_connection = null
	else:
		var c = g.connection.instance()
		world.add_child(c)
		c.start(port)
		port.connection = c
		active_connection = c

func remove_connection(conn):
	if conn.port_start:
		conn.port_start.connected_port = null
		conn.port_start.connection = null
	if conn.port_end:
		conn.port_end.connected_port = null
		conn.port_end.connection = null
	conn.queue_free()

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		if event.pressed:
			if active_connection:
				remove_connection(active_connection)
				active_connection = null
			if active_device:
				active_device.queue_free()
				active_device = null
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:

		if event.pressed:
			if active_device:
				active_device.modulate = Color.white
				active_device = null
		
		left_pressed = event.pressed
				
	if event is InputEventMouseMotion and left_pressed:
		if not active_device and not active_connection:
	        world.move_local_x(event.relative.x)
	        world.move_local_y(event.relative.y)
		
	# when setting device stop input from propagating
	if active_device:
		get_tree().set_input_as_handled()


				
func _process(delta):	
	if active_device:
		active_device.global_position = get_global_mouse_position()
		active_device.modulate = Color.gray
		


func set_active_device(dev:Node2D):
	if active_device:
		active_device.queue_free()
	active_device = dev
	
func _on_create_server_pressed():
	var dev = g.server.instance()
	world.add_child(dev)
	set_active_device(dev)	

func _on_create_router_pressed():
	var dev = g.router.instance()
	world.add_child(dev)
	set_active_device(dev)
