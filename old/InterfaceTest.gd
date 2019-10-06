extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var vpw = get_viewport_rect().size.x
	var vph = get_viewport_rect().size.y
	
#	for x in range(int(vpw/g.grid_size) + 1):
#		draw_line(Vector2(x*g.grid_size, 0), Vector2(x*g.grid_size, vph), Color.darkkhaki)
#
#	for y in range(int(vph/g.grid_size) + 1):
#		draw_line(Vector2(0, y*g.grid_size), Vector2(vpw, y*g.grid_size), Color.darkkhaki)
