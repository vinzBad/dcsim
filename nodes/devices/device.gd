class_name Device
extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var device_type = "DEVICE"

onready var uid = g.get_uid()
onready var ports = $ports
onready var services = $services
onready var control = $control
onready var label = $control/label
onready var world = get_parent().get_parent()

var type_name = "device"

var is_hovering = false
var is_selected = false
var is_active = false

var is_bridge = true

var hostname = ""
var height = 2

func start():
	g.packet_nav.add_point(uid, Vector3(global_position.x, global_position.y, 0))
	add_to_group(device_type)
	is_active = true
	
	for port in ports.get_children():
		g.packet_nav.add_point(port.uid, Vector3(port.global_position.x, port.global_position.y, 0))
		if is_bridge:
			g.packet_nav.connect_points(uid, port.uid)

func get_service():
	for s in services.get_children():
		return s
	return null
	
func stop():
	g.packet_nav.remove_point(uid)
	remove_from_group(device_type)
	is_active = false
	
	for port in ports.get_children():
		g.packet_nav.remove_point(port.uid)
	
func _ready():
	add_to_group(g.NEED_UPDATE_COLORSCHEME)

func _draw():
	var color = Color(g.colorscheme["device"][self.device_type])
	var bg = Color(g.colorscheme["background"])
	var inner_color = color.darkened(0.75)
	var hover_color = inner_color.lightened(0.3)
	var select_color = hover_color.darkened(0.15)
	
	var rect = Rect2($control.rect_position, $control.rect_size)
	var innerer_rect = Rect2(rect.position + Vector2(3,3), rect.size - Vector2(6,6))
	var inner_rect = Rect2(rect.position + Vector2(1,1), rect.size - Vector2(2,2))

	draw_rect(rect, bg)
	draw_rect(inner_rect, color)
	draw_rect(innerer_rect, inner_color)
	
	if is_active:			
		if is_hovering:
			draw_rect(innerer_rect, hover_color)
		elif is_selected:
			draw_rect(innerer_rect, select_color)
	
	

func get_port_to_uid(uid):
	for port in $ports.get_children():
		if port.state == Port.UP:
			if port.other_port().uid == uid:
				return port
	return null

func port_up(my_port):
	var other_port = my_port.other_port()
	if !g.packet_nav.are_points_connected(my_port.uid, other_port.uid):
		g.packet_nav.connect_points(my_port.uid, other_port.uid)

func port_down(my_port):
	var other_port = my_port.other_port()
	if other_port != null:
		if g.packet_nav.are_points_connected(my_port.uid, other_port.uid):
			g.packet_nav.disconnect_points(my_port.uid, other_port.uid)

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
		"height": self.height
	}
	
	for port in ports.get_children():
		var is_disabled = (port.state == Port.DISABLED)
		data["ports"].append({
			"pos_x": port.position.x,
			"pos_y": port.position.y,
			"name": port.port_name,
			"is_disabled": is_disabled,
			"is_bridge": is_bridge
		})
		
	if services.get_child_count() > 0:
		var s = services.get_children()[0]
		var sd = {}
		sd["pos_x"] = s.position.x
		sd["pos_y"] = s.position.y
		sd["service_name"] = s.service_name
		sd["in_use"] = s.in_use
		data["service"] = sd
	
	return data

func register():
	g.uid2device[uid] = self
	for port in ports.get_children():
		g.uid2device[port.uid] = port
	g.hostname2device[hostname] = self
	
func is_moveable():
	for port in ports.get_children():
		if port.has_conn():
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
	
	if device_type == "server":
		data["is_bridge"] = false
	self.is_bridge = data.get("is_bridge", true)
	

	for pd in data["ports"]:
		var p  = g.port.instance()
		ports.add_child(p)
		p.position = Vector2(pd["pos_x"], pd["pos_y"])
		p.port_name = pd["name"]
		p.device = self
		if pd.get("is_disabled", false):
			p.disable()
		p.register()
	self.register()
	if not data.has("service") and device_type == "server":
		data["service"] = {}
		data["service"]["pos_x"] = 85
		data["service"]["pos_y"] = 15
		data["service"]["service_name"] = "empty"
		data["service"]["in_use"] = false
	

		
	if data.has("service"):
		var sd = data["service"]
		var s = g.service.instance()
		services.add_child(s)
		s.position = Vector2(sd["pos_x"], sd["pos_y"])
		s.service_name = sd["service_name"]
		s.device = self
		s.in_use = sd["in_use"]
	
	
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
		
