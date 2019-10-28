extends CanvasLayer

export var camera_path:NodePath
onready var camera:Camera2D = get_node(camera_path)

enum {IDLE, PLACING, CONNECTING}
var device:Device
var selected_service
var selected_device:Device
var selected_port:Port
var connection:Connection
var state = IDLE
var file_names = []
var colorschemes = []
var is_dragging = false
var tick_speed = 0

onready var file_select:OptionButton = $hbox/margin_buttons/vbox_buttons/file
onready var colorscheme_select:OptionButton = $hbox_colorscheme/colorschemeselect

onready var site_label:Label = $hbox/margin_labels/hbox/vbox_values/site
onready var money_label:Label = $hbox/margin_labels/hbox/vbox_values/money
onready var cashflow_label:Label = $hbox/margin_labels/hbox/vbox_values/cashflow
onready var queue_label:Label = $hbox/margin_labels/hbox/vbox_values/servicequeue
onready var speed_label = $hbox/margin_labels/hbox/vbox_values/speed

onready var uplink_button:Button = $hbox/margin_buttons/vbox_buttons/hbox/vbox/uplink
onready var router_button:Button = $hbox/margin_buttons/vbox_buttons/hbox/vbox/router
onready var switch_button:Button = $hbox/margin_buttons/vbox_buttons/hbox/vbox/switch
onready var server_button:Button = $hbox/margin_buttons/vbox_buttons/hbox/vbox/server

onready var device_view = $hbox/margin_labels/hbox/vbox_labels/hbox_device

onready var timer:Timer = $timer

func _ready():
	md.connect_message(g.ERROR, self, "_handler")
	md.connect_message(g.SITE_NAME_CHANGE, self, "_handler")
	md.connect_message(g.SELECT_DEVICE, self, "_handler")
	md.connect_message(g.SELECT_PORT, self, "_handler")
	md.connect_message(g.RESET, self, "_handler")
	md.connect_message(g.MOVE_DEVICE, self, "_handler")
	md.connect_message(g.REMOVE_DEVICE, self, "_handler")
	md.connect_message(g.SELECT_SERVICE, self, "_handler")
	_set_file_options()
	_set_colorscheme_options()
	_set_button_prices()
	
	#device_view.visible = false
	
func _process(delta):
	if state == PLACING:
		handle_placing()
	money_label.text = "%.2f €" % g.money
	queue_label.text = "%s" % g.queue
	cashflow_label.text = "%.2f €" % g.cashflow
	

func handle_placing():
	device.global_position = g.ridify(device.get_global_mouse_position())

func _input(event):
	if event.is_action_pressed("gui_cancel"):
		if state == IDLE:
			select_device(null)
			select_port(null)
			select_service(null)
		if state == PLACING:
			get_parent().remove_child(device)
			device.queue_free()
			g.hostname_counter[device.device_type] -= 1
			device = null
			state = IDLE
		if state == CONNECTING:
			get_parent().remove_child(connection)
			connection.remove()
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
	device_view.visible = false
	device_view.set_device(device)
	if selected_device != null:
		selected_device.is_selected = false
		selected_device.update()
	
	if device:
		selected_device = device
		selected_device.is_selected = true
		selected_device.update()
		if selected_port and selected_port.device != selected_device:
			select_port(null) # this is so ugly
		device_view.visible = true
		device_view.hide()
		device_view.show()
	else:
		selected_device = null

func select_port(port):
	device_view.set_port(port)
	
	if selected_port:
		select_device(null)
		selected_port.is_selected = false
		selected_port.update()
	
	if port:
		selected_port = port
		selected_port.is_selected = true
		selected_port.update()		
		if port.device != selected_device:
			select_device(port.device)
	else:
		selected_port = null
	
func select_service(service):
	if selected_service:
		selected_service.is_selected = false
		selected_service.update()
	
	selected_service = service
	if service:
		selected_service.is_selected = true
		selected_service.update()

func start_connecting(port):
	state = CONNECTING

	connection = g.connection.instance()
	connection.start_on(port)
	get_parent().add_child(connection)
	
func finish_connecting(port):
	if connection.port_start == port:
		return
		
	if connection.port_start.device == port.device:
		return
	
	connection.finish_on(port)
	
	get_parent().remove_child(connection)	
	md.emit_message(g.ADD_CONNECTION, {"connection":connection})
	
	connection = null
	state = IDLE
	
	device_view.update_button_labels()

func start_placing(device_type):
	state = PLACING
	if device:
		device.queue_free()
	device = g.device.instance()
	get_parent().add_child(device)
	device.init_from_def(g.defs[device_type])
	

func _set_button_prices():
	yield(get_tree(), "idle_frame")
	uplink_button.text = "uplink[1] %s €" % g.defs["uplink"]["price"]["fixed"]
	router_button.text = "router[2] %s €" % g.defs["router"]["price"]["fixed"]
	switch_button.text = "switch[3] %s €" % g.defs["switch"]["price"]["fixed"]
	server_button.text = "server[4] %s €" % g.defs["server"]["price"]["fixed"]

func _handler(type, msg):
	if type == g.RESET:
		if device:
			device.queue_free()
		device = null
		selected_device = null
		selected_port = null
		if connection:
			connection.queue_free()
		state = IDLE
		_set_colorscheme_options()
		_set_button_prices()
		
	if type == g.ERROR:
		print("%s: %s" % [type, msg["error"]])
	elif type == g.SITE_NAME_CHANGE:
		site_label.text = msg["name"]
	elif type == g.SELECT_DEVICE and state == IDLE:
		select_device(msg["device"])
	elif type == g.SELECT_PORT and state == IDLE:
		select_port(msg["port"])
		if !msg["port"].has_conn():
			start_connecting(msg["port"])
	elif type == g.SELECT_PORT and state == CONNECTING:
		select_port(msg["port"])
		finish_connecting(msg["port"])
	elif type == g.MOVE_DEVICE:
		select_device(null)
		select_port(null)
		state = PLACING		
		device = msg["device"]
		var price = g.defs[device.device_type]["price"]["fixed"]
		g.money += price
		for p in device.ports.get_children():
			if p._conn:
				p._conn.remove()
		device.is_active = false
		var owner = device.get_parent()
		owner.remove_child(device)
		device.set_owner(get_parent())
		get_parent().add_child(device)
	elif type == g.REMOVE_DEVICE:
		if msg["device"] == selected_device:
			selected_device = null
			selected_port = null
			select_device(null)
			select_port(null)
		
		device = msg["device"]
		var price = g.defs[device.device_type]["price"]["fixed"]
		g.money += price
		msg["device"].remove()
	elif type == g.SELECT_SERVICE and state == IDLE:
		select_service(msg["service"])

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

func _set_colorscheme_options():
	colorschemes.clear()
	colorscheme_select.clear()
	var dir = Directory.new()
	var default_idx = 0
	if dir.open("res://content/colorschemes/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if !dir.current_is_dir() and file_name.ends_with(".json"):
				colorscheme_select.add_item(file_name.get_basename(), len(colorschemes))
				if file_name.begins_with("default"):
					default_idx = len(colorschemes)
				colorschemes.append("res://content/colorschemes/"+file_name)

			file_name = dir.get_next()
	if colorscheme_select.selected == -1:
		colorscheme_select.select(default_idx)

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
	
	md.emit_message(g.RESET, {})
	md.emit_message(g.LOAD, {"file": file})


func _on_reset_pressed():
	md.emit_message(g.RESET, {})


func _on_uplink_pressed():
	if state == IDLE or state == PLACING:
		start_placing("uplink")


func _on_router_pressed():
	if state == IDLE or state == PLACING:
		start_placing("router")
	#

func _on_switch_pressed():
	if state == IDLE or state == PLACING:
		start_placing("switch")


func _on_server_pressed():
	if state == IDLE or state == PLACING:
		start_placing("server")


func _on_colorschemeselect_item_selected(ID):
	g.load_colors(colorschemes[ID])
	get_tree().call_group(g.NEED_UPDATE_COLORSCHEME, "update")

func _on_reload_pressed():
	g.load_colors(colorschemes[colorscheme_select.selected])
	get_tree().call_group(g.NEED_UPDATE_COLORSCHEME, "update")
	_set_colorscheme_options()


func _on_play_pressed():
	tick_speed = 1
	timer.wait_time = 1
	speed_label.text = "NORMAL"
	if timer.is_stopped():
		timer.start()
	
func _on_pause_pressed():
	speed_label.text = "PAUSE"
	timer.stop()


func _on_fast_pressed():
	tick_speed = 0.25
	timer.wait_time = 0.25
	speed_label.text = "FAST"
	if timer.is_stopped():
		timer.start()


func _on_timer_timeout():
	md.emit_message(g.TICK, {"speed": tick_speed})


func _on_slomo_pressed():
	tick_speed = 2
	timer.wait_time = 2
	speed_label.text = "SLOW"
	if timer.is_stopped():
		timer.start()

