extends CanvasLayer

export var camera_path:NodePath
onready var camera:Camera2D = get_node(camera_path)

enum {IDLE, PLACING, CONNECTING}
var device:Device
var selected_device:Device
var connection:Connection
var state = IDLE
var file_names = []
var is_dragging = false

onready var file_select:OptionButton = $hbox/margin_buttons/vbox_buttons/file
onready var site_label:Label = $hbox/margin_labels/hbox/vbox_values/site


func _ready():
	md.connect_message(g.ERROR, self, "_handler")
	md.connect_message(g.SITE_NAME_CHANGE, self, "_handler")
	md.connect_message(g.SELECT_DEVICE, self, "_handler")
	md.connect_message(g.SELECT_PORT, self, "_handler")
	_set_file_options()
	
func _process(delta):
	if state == PLACING:
		handle_placing()

func handle_placing():
	device.global_position = g.ridify(device.get_global_mouse_position())

func _input(event):
	if event.is_action_pressed("gui_cancel"):
		select_device(null)
		if state == PLACING:
			get_parent().remove_child(device)
			device.queue_free()
			g.hostname_counter[device.device_type] -= 1
			device = null
			state = IDLE
		if state == CONNECTING:
			get_parent().remove_child(connection)
			connection.queue_free()
			connection = null
			state = IDLE
		
	if state == PLACING and event.is_action_pressed("gui_place_device"):
		get_parent().remove_child(device)
		var screen_pos = device.position
		md.emit_message(g.ADD_DEVICE, { "device": device, "pos": screen_pos })		
		device = null
		state = IDLE
	
	if event.is_action_pressed("gui_start_drag"):
		is_dragging = true
		
	if event.is_action_released("gui_start_drag"):
		is_dragging = false	

	if is_dragging and event is InputEventMouseMotion:
		camera.move_local_x(event.relative.x * 2) 
		camera.move_local_y(event.relative.y * 2)

func select_device(device):
	if selected_device:
		selected_device.is_selected = false
		selected_device.update()
	if device:
		selected_device = device
		selected_device.is_selected = true
		selected_device.update()
		
func start_connecting(port):
	state = CONNECTING
	if port.connected_port:
		remove_connection(port.connection)
	connection = g.connection.instance()
	connection.start(port)
	port.connection = connection
	get_parent().add_child(connection)
	
func finish_connecting(port):
	if connection.port_start == port:
		return
		
	if connection.port_start.device == port.device:
		return
	
	if port.connected_port:
		remove_connection(port.connection)
	
	connection.finish(port)
	port.connection = connection
	connection.port_start.connected_port = port
	port.connected_port = connection.port_start
	
	get_parent().remove_child(connection)	
	md.emit_message(g.ADD_CONNECTION, {"connection":connection})
	
	connection = null
	state = IDLE

func start_placing(device_type):
	state = PLACING		
	device = g.device.instance()
	get_parent().add_child(device)
	device.init_from_def(g.defs[device_type])
	

func remove_connection(conn):
	if conn.port_start:
		conn.port_start.connected_port = null
		conn.port_start.connection = null
	if conn.port_end:
		conn.port_end.connected_port = null
		conn.port_end.connection = null
	conn.queue_free()

func _handler(type, msg):
	if type == g.ERROR:
		print("%s: %s" % [type, msg["error"]])
	elif type == g.SITE_NAME_CHANGE:
		site_label.text = msg["name"]
	elif type == g.SELECT_DEVICE and state == IDLE:
		select_device(msg["device"])
	elif type == g.SELECT_PORT and state == IDLE:
		start_connecting(msg["port"])	
	elif type == g.SELECT_PORT and state == CONNECTING:
		finish_connecting(msg["port"])

func _set_file_options():
	file_names.clear()
	file_select.clear()
	var dir = Directory.new()
	if dir.open("user://") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if !dir.current_is_dir() and file_name.ends_with(".json"):
				file_select.add_item(file_name, len(file_names))
				file_names.append("user://"+file_name)				
			file_name = dir.get_next()


func _on_save_pressed():
	var file = null
	if file_select.selected > -1:
		file = file_names[file_select.selected]	
	md.emit_message(g.SAVE, {"file": file})
	_set_file_options()

func _on_load_pressed():
	var file = null
	if file_select.selected > -1:
		file = file_names[file_select.selected]	
	md.emit_message(g.LOAD, {"file": file})


func _on_reset_pressed():
	md.emit_message(g.RESET, {})


func _on_uplink_pressed():
	if state == IDLE:
		start_placing("uplink")


func _on_router_pressed():
	if state == IDLE:
		start_placing("router")
	#

func _on_switch_pressed():
	if state == IDLE:
		start_placing("switch")


func _on_server_pressed():
	if state == IDLE:
		start_placing("server")
