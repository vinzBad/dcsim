extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var width = 1 * g.grid_size
var height = 1 * g.grid_size
var color = Color.greenyellow

onready var rect = Rect2(0,0,width, height)

var is_hovering = false
var is_selected = false
var service_name = null
var device = null

onready var control = $control
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _draw():
	var active = Color(g.colorscheme["service"]["active"])
	var outline = Color(g.colorscheme["service"]["outline"])
	var disabled = Color(g.colorscheme["service"]["disabled"])
	var bg = Color(g.colorscheme["background"])
	
	var hover_color = active.darkened(0.45)
	
	var rect = Rect2($control.rect_position, $control.rect_size)
	var hover_rect = Rect2(rect.position + Vector2(3,3), rect.size - Vector2(6,6))
	var select_rect = Rect2(rect.position - Vector2(2,2), rect.size + Vector2(4,4))
	var conn_rect = Rect2(rect.position + Vector2(5,5), rect.size - Vector2(10,10))
	
	if is_selected:
		draw_rect(select_rect, Color(g.colorscheme["service"]["selected"]))
	
	draw_rect(rect, outline)	
	draw_rect(hover_rect, bg)
	
	if is_hovering:
		draw_rect(hover_rect, hover_color)	


func _on_control_mouse_entered():
	is_hovering = true
	update()

func _on_control_mouse_exited():
	is_hovering = false
	update()

func _on_control_gui_input(event):
	if is_hovering:
		if event.is_action_pressed("gui_select_device"):
			md.emit_message(g.SELECT_SERVICE, {"service": self})