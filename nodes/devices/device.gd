class_name Device
extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var color = Color.green
export var hover_color = Color.black
export var select_color = Color.white

export var device_type = "DEVICE"

onready var uid = g.get_uid()
onready var ports = $ports
onready var control = $control
onready var label = $control/label
onready var world = get_parent().get_parent()

var is_hovering = false
var is_selected = false
var is_active = false

var hostname = ""
var height = 2

func start():
	g.packet_nav.add_point(uid, Vector3(global_position.x, global_position.y, 0))
	add_to_group(device_type)
	is_active = true

	
func stop():
	g.packet_nav.remove_point(uid)
	remove_from_group(device_type)
	is_active = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var rect = Rect2($control.rect_position, $control.rect_size)
	var height = rect.size.y
	var width = rect.size.x
	draw_rect(rect, Color.black, true)
	if is_active:			
		if is_hovering:
			draw_rect(rect, hover_color, true)
		elif is_selected:
			draw_rect(rect, select_color, true)
	
	draw_rect(rect, color, false)
	for p in [Vector2.ZERO, Vector2(0, height), Vector2(width, 0), Vector2(width, height)]:
		draw_circle(p, 4, color)

func get_port_to_uid(uid):
	for port in $ports.get_children():
		if port.connected_port:
			if port.connected_port.device.uid == uid:
				return port
	return null

func port_up(my_port):
	var other_port = my_port.other_port()
	if !g.packet_nav.are_points_connected(uid, other_port.device.uid):
		g.packet_nav.connect_points(uid, other_port.device.uid)

func port_down(my_port):
	var other_port = my_port.other_port()
	if other_port != null:
		if g.packet_nav.are_points_connected(uid, other_port.device.uid):
			g.packet_nav.disconnect_points(uid, other_port.device.uid)

func remove():
	self.stop()
	for port in ports.get_children():
		if port._conn:
			port._conn.remove()
	self.queue_free()

func save():
	var data = {
		"hostname": self.hostname,
		"device_type": self.device_type,
		"ports":[],
		"services":[],
		"height": self.height
	}
	
	for port in ports.get_children():
		var is_disabled = (port.state == Port.DISABLED)
		data["ports"].append({
			"pos_x": port.position.x,
			"pos_y": port.position.y,
			"name": port.port_name,
			"is_disabled": is_disabled
		})
	
	return data

func register():
	g.uid2device[uid] = self
	g.hostname2device[hostname] = self
	
func is_moveable():
	for port in ports.get_children():
		if port.state == Port.UP:
			return false
	return true

func init_from_def(def):
	def["hostname"] = g.get_hostname(def)

	for i in range(len(def["ports"])):
		var pd = def["ports"][i] 
		def["ports"][i]["pos_x"] = pd["x"] * g.grid_size
		def["ports"][i]["pos_y"] = pd["y"] * g.grid_size
		
	load_from_save(def)	


func load_from_save(data:Dictionary):
	self.hostname = data["hostname"]
	self.label.text = hostname
	self.device_type = data["device_type"]
	self.height = data.get("height", 2)
	self.control.rect_size.y = height * g.unit_height
	self.register()
	for pd in data["ports"]:
		var p  = g.port.instance()
		ports.add_child(p)
		p.position = Vector2(pd["pos_x"], pd["pos_y"])
		p.port_name = pd["name"]
		p.device = self
		if pd.get("is_disabled", false):
			p.disable()
		p.register()
	
	start()
	yield(get_tree(), "idle_frame")
	self.set_name(hostname)
	
	
func _on_control_mouse_entered():
	is_hovering = true
	update()


func _on_control_mouse_exited():
	is_hovering = false
	update()


func _on_control_gui_input(event:InputEvent):
	if !is_active:
		return
	
	if is_hovering and event.is_action_pressed("gui_select_device"):
		md.emit_message(g.SELECT_DEVICE, {"device": self})
		
