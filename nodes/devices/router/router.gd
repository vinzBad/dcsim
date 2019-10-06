tool
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var width = 6 * g.grid_size
var height = 2 * g.grid_size
var color = Color.green

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	draw_rect(Rect2(Vector2.ZERO, Vector2(width, height)), color, false)
	for p in [Vector2.ZERO, Vector2(0, height), Vector2(width, 0), Vector2(width, height)]:
		draw_circle(p, 4, color)
