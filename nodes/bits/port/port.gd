tool
extends Node2D
class_name Port
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var color = Color.green
var is_hovering = false
var is_selected = false
var device:Device = null

var connection = null
var connected_port = null setget set_c, get_c
var _c = null
var port_name = ""

func set_c(c):
	if c == null:
		device.port_down(self, _c)
	else:
		device.port_up(self, c)
	_c = c
	update()

func get_c():
	return _c


func register():
	g.register_port(device, self)
	yield(get_tree(), "idle_frame")
	self.set_name(port_name)

func _draw():
	var rect = Rect2($control.rect_position, $control.rect_size)
	var hover_rect = Rect2(rect.position + Vector2(2,2), rect.size - Vector2(4,4))
	var select_rect = Rect2(rect.position - Vector2(2,2), rect.size + Vector2(4,4))
	
	if is_selected:
		draw_rect(select_rect, Color.gold)
	
	draw_rect(rect, color)	
	draw_rect(hover_rect, Color.black)
	
	if connection:
		draw_rect(hover_rect, Color.gray)
	if _c:
		draw_rect(hover_rect, Color.azure)
	if is_hovering:
		draw_rect(hover_rect, color)	


func _on_control_mouse_entered():
	is_hovering = true
	update()

func _on_control_mouse_exited():
	is_hovering = false
	update()

func _on_control_gui_input(event):
	if is_hovering:
		if event.is_action_pressed("gui_select_device"):
			md.emit_message(g.SELECT_PORT, {"port": self})
