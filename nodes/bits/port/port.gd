tool
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var color = Color.green
var is_hovering = false
var device:Device = null

var connection = null
var connected_port = null setget set_c, get_c
var _c = null


func set_c(c):
	if c == null:
		device.port_down(self, _c)
	else:
		device.port_up(self, c)
	_c = c
	update()

func get_c():
	return _c

func _unhandled_input(event):
	if is_hovering:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			if event.pressed:
				get_tree().call_group(g.NEEDS_PORT_CLICK, "on_port_click", self)

func _ready():
	device = get_parent().get_parent()
	


func _draw():
	var rect = Rect2($control.rect_position, $control.rect_size)
	var hover_rect = Rect2(rect.position + Vector2(2,2), rect.size - Vector2(4,4))
	draw_rect(rect, color)
	
	if !is_hovering :
		draw_rect(hover_rect, Color.black)
		
	if _c and !is_hovering:
		draw_rect(hover_rect, Color.azure)
	

func _on_control_mouse_entered():
	is_hovering = true
	update()

func _on_control_mouse_exited():
	is_hovering = false
	update()

func _on_control_gui_input(event):
	_unhandled_input(event)
