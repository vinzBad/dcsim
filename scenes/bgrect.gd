extends Node2D

func _ready():
	add_to_group(g.NEED_UPDATE_COLORSCHEME)
	yield(get_tree(), "idle_frame")
	update()
	
func _draw():
	var color = g.colorscheme.get("background", Color.black)
	draw_rect(get_viewport_rect(), color)