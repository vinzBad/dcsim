extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var width = 1 * g.grid_size
var height = 1 * g.grid_size
var color = Color.greenyellow

onready var rect = Rect2(0,0,width, height)

var is_hovering = false
var in_use = false
var has_path_to_uplink = false
var service_name = null
var device = null

var uplink
var port

onready var control = $control
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(g.NEED_UPDATE_COLORSCHEME)


func is_up(uplinks):
	update()
	for pot_uplink in uplinks:
		port = port_to(pot_uplink)
		if port:
			uplink = pot_uplink
			has_path_to_uplink = true
			return true
	has_path_to_uplink = false
	return false

func port_to(uplink):
	for device_port in device.ports.get_children():
			if device_port.state != Port.UP:
				continue
			var path = g.packet_nav.get_id_path(device_port.uid, uplink.uid)
			if path:
				return device_port
	return null


func go_live():
	in_use = true
	

func _draw():
	var active = Color(g.colorscheme["service"]["active"])
	var inactive = Color(g.colorscheme["service"]["inactive"])
	var outline = Color(g.colorscheme["service"]["outline"])
	var down = Color(g.colorscheme["service"]["down"])


	var rect = Rect2($control.rect_position, $control.rect_size)
	var hover_rect = Rect2(rect.position + Vector2(3,3), rect.size - Vector2(6,6))


	
	draw_rect(rect, outline)	
	draw_rect(hover_rect, inactive)
	
	if in_use:
		draw_rect(hover_rect, active)
	if !has_path_to_uplink:
		draw_rect(hover_rect, down)

