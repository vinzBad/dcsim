extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	load_save()

func reset():
	g.packet_nav = AStar.new()
	for child in get_children():
		child.queue_free()


func save():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	for child in get_children():
		if !child.has_method("save"):
			continue
		var data = {
				"filename": child.filename,
				"name": child.name,
				"pos_x": child.position.x,
				"pos_y": child.position.y,
				"data": child.save()
			}
		# FIXME: Proper saving / loading of nodepaths
		save_game.store_line(to_json(data).replace("@", "_"))
	save_game.close()
		
	
func load_save():
	
	reset()
	
	# wait for children to be freed
	yield(get_tree(), "idle_frame")
	
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	save_game.open("user://savegame.save", File.READ)
	while not save_game.eof_reached():
		var line = save_game.get_line()
		var data = parse_json(line)
		if data == null:
			continue
		var n = load(data["filename"]).instance()		
		n.position = Vector2(data["pos_x"], data["pos_y"])
		add_child(n, true)
		
		n.set_name(data["name"])
		if data["name"] != n.get_name():
			print("name change!" + data["name"] + " -> " + n.get_name())
		n.load(data["data"])
		
	save_game.close()


func _on_load_pressed():
	load_save()


func _on_save_pressed():
	save()

func _process(delta):
	update()

func _draw():
	return
	for p in g.packet_nav.get_points():
		var pos = g.packet_nav.get_point_position(p)
		draw_circle(to_local(Vector2(pos.x, pos.y)), 10, Color.gold)
		for c in g.packet_nav.get_point_connections(p):
			var opos = g.packet_nav.get_point_position(c)
			draw_line(to_local(Vector2(pos.x, pos.y)), to_local(Vector2(opos.x, opos.y)), Color.gold, 2, true)