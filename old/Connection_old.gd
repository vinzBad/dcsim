extends Node2D

var a_port = null
var b_port = null

var segments = [Vector2.ZERO]
var current_segment_index = 0

var is_active = true

func _ready():
	pass

func _input(event):
	if not is_active:
		return
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			
			if current_segment_index > 1:
				var lls = segments[current_segment_index-2]
				var ls = segments[current_segment_index-1]
				var s = segments[current_segment_index]
				if lls.y == ls.y and ls.y == s.y:
					segments[current_segment_index-1].x = s.x
					return
				elif lls.x == ls.x and ls.x == s.x:
					segments[current_segment_index-1].y = s.y
					return
				
			current_segment_index += 1
			
			
	
func start_with_port(port:Node2D):
	a_port = port
	self.position = to_local(port.global_position)
	
func finish_with_port(port:Node2D):
	b_port = port
	is_active = false
	var ls = segments.back()
	var p = to_local(port.global_position)
	var d = ls - p
	var s = Vector2.ZERO
	if abs(d.x) > abs(d.y):
		segments[len(segments)-1].y = p.y
	else:
		segments[len(segments)-1].x = p.x
	segments.append(p)
	update()
	

func _process(delta):
	if not is_active:
		return
	
	update()
	
	var mp = get_local_mouse_position()
	var ls = Vector2.ZERO	
	if current_segment_index > 0:
		ls = segments[current_segment_index-1]
	var d = ls - mp
	var s = Vector2.ZERO
	if abs(d.x) > abs(d.y):
		s = g.ridify(Vector2(mp.x, ls.y))
	else:
		s = g.ridify(Vector2(ls.x, mp.y))
	
	if current_segment_index >= len(segments):
		segments.append(s)
	else:
		segments[current_segment_index] = s
	

func _draw():
	var ls = Vector2.ZERO
	draw_circle(Vector2.ZERO, 6, Color.gold)
	for segment in segments:
		draw_circle(ls, 5, Color.green)
		draw_line(ls, segment, Color.green, 3)
		ls = segment
	
	if is_active:
		draw_circle(ls, 3, Color.green)
		var s = segments[current_segment_index]
		var mp = g.ridify(get_local_mouse_position())	
		draw_line(s, mp, Color.green)

		
