tool
extends Node2D
class_name Port

enum {UP, DOWN, DISABLED}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var port_name = ""

var is_hovering = false
var is_selected = false
var device = null
var state = DOWN

var _conn: Connection

func other_port():
	if _conn:
		return _conn.other_port(self)
	return null

func set_conn(conn:Connection):
	remove_conn()
	self._conn = conn
	
	var other = other_port()
	if other != null and other.state != DISABLED and self.state != DISABLED:
		state = UP		
		device.port_up(self)
		other.state = UP
		other.device.port_up(other)
		other.update()
	update()

func remove_conn():
	if !_conn:
		return
	_conn = null
	if state == UP:
		state = DOWN
		device.port_down(self)
	update()
	
func disable():
	if state == DISABLED:
		return
	state = DISABLED
	var other = other_port()
	if other != null and other.state == UP:
		other.state = DOWN
		other.device.port_down(other)
		other.update()
	update()

func enable():
	if state != DISABLED:
		return
	
	var other = other_port()
	if other != null and other.state != DISABLED:
		state = UP
		device.port_up(self)
		other.state = UP
		other.device.port_up(other)
		other.update()
	else:
		state = DOWN
	update()
	
func has_conn():
	return _conn != null

func register():
	g.register_port(device, self)
	yield(get_tree(), "idle_frame")
	self.set_name(port_name)

func _draw():
	var active = Color(g.colorscheme["port"]["active"])
	var outline = Color(g.colorscheme["port"]["outline"])
	var disabled = Color(g.colorscheme["port"]["disabled"])
	var bg = Color(g.colorscheme["background"])
	
	var hover_color = active.blend(bg).lightened(0.3)
	
	var rect = Rect2($control.rect_position, $control.rect_size)
	var hover_rect = Rect2(rect.position + Vector2(2,2), rect.size - Vector2(4,4))
	var select_rect = Rect2(rect.position - Vector2(2,2), rect.size + Vector2(4,4))
	var conn_rect = Rect2(rect.position + Vector2(5,5), rect.size - Vector2(10,10))
	
	if is_selected:
		draw_rect(select_rect, Color.gold)
	
	draw_rect(rect, outline)	
	draw_rect(hover_rect, bg)
	
	if _conn:
		draw_rect(conn_rect, active)
	
	if state == DISABLED:
		draw_rect(hover_rect, disabled)
	
	if state == UP:
		draw_rect(hover_rect, active)
	
	if is_hovering:
		draw_rect(hover_rect, hover_color)	

func state_as_string():
	return {UP:"Up", DOWN:"Down", DISABLED:"Disabled"}.get(state)


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
