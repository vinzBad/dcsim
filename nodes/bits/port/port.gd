tool
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var color = Color.green
var radius = 6
var is_hovering = false

var connection = null
var connected_port = null setget set_c, get_c
var _c = null
func set_c(c):
	_c = c
	update()

func get_c():
	return _c

func _unhandled_input(event):
	if is_hovering:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			if event.pressed:
				get_tree().call_group(g.NEEDS_PORT_CLICK, "on_port_click", self)


func _process(delta):
	if get_local_mouse_position().length() < radius:
		is_hovering = true
		update()
	elif is_hovering:
		is_hovering = false
		update()

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
	
	if !is_hovering :
		draw_circle(Vector2.ZERO, radius - 2, Color.black)
		
	if _c and !is_hovering:
		draw_circle(Vector2.ZERO, radius -2, Color.azure)
	

		

		

	
