extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	
func _draw():
	for p in g.packet_nav.get_points():
		var pos = g.packet_nav.get_point_position(p)
		draw_circle(to_local(Vector2(pos.x, pos.y)), 3, Color.gold)
		for c in g.packet_nav.get_point_connections(p):
			var opos = g.packet_nav.get_point_position(c)
			draw_line(to_local(Vector2(pos.x, pos.y)), to_local(Vector2(opos.x, opos.y)), Color.gold, 1, true)
