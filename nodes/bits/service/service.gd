tool
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var width = 1 * g.grid_size
var height = 1 * g.grid_size
var color = Color.greenyellow

onready var rect = Rect2(0,0,width, height)

var is_hovering = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	is_hovering = rect.has_point(get_local_mouse_position())
	update()

func _draw():
	draw_line(Vector2.ZERO, Vector2(0, height), color, 3)
	draw_line(Vector2.ZERO, Vector2(width, 0), color, 3)
	draw_line( Vector2(0, height), Vector2(width, height), color, 3)
	draw_line( Vector2(width, 0), Vector2(width, height), color, 3)
	
	if is_hovering:
		draw_rect(Rect2(1, 1, width -2, height -2), color)