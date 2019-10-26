extends Node2D
class_name SimWorld

export var camera_path:NodePath
onready var camera:Camera2D = get_node(camera_path)

var site_name = "l33t.io"

onready var entities = $entities

func _ready():
	md.connect_message(g.TICK, self, "tick")
	md.connect_message(g.LOAD, self, "load_save")
	md.connect_message(g.SAVE, self, "save")
	md.connect_message(g.RESET, self, "reset")
	md.connect_message(g.ADD_DEVICE, self, "add_device")
	md.connect_message(g.ADD_CONNECTION, self, "add_connection")
	

func tick(t, msg):
	var uplinks = get_tree().get_nodes_in_group("uplink")
	var switches = get_tree().get_nodes_in_group("switch")
	var routers = get_tree().get_nodes_in_group("router")
	var servers = get_tree().get_nodes_in_group("server")

	
	g.cashflow = 0
	g.cashflow -= len(uplinks) * g.defs["uplink"]["price"]["pertick"]
	g.cashflow -= len(routers) * g.defs["router"]["price"]["pertick"]
	g.cashflow -= len(switches) * g.defs["switch"]["price"]["pertick"]
	g.cashflow -= len(servers) * g.defs["server"]["price"]["pertick"]
	
	for server in servers:
		var service = server.get_service()
		if service == null:
			continue
		if service.in_use:
			if service.is_up():
				g.cashflow += 0.4
		elif g.queue > 0 and randf() > 0.8:
			g.queue -= 1
			service.in_use = true
			service.update()
		
	g.money += g.cashflow
	
	
func load_save(t, msg):
	var success
	if msg["file"]:
		success = _load_save(msg["file"])
	else:
		success = _load_save()
	if !success:
		reset()
		
func save(t, msg):
	if msg["file"]:
		_save(msg["file"])
	else:
		_save()
	
func reset(t=null, msg=null):	
	for entity in entities.get_children():
		entity.queue_free()

func add_device(t, msg):
	var d:Device = msg["device"]
	var price = g.defs[d.device_type]["price"]["fixed"]
	g.money -= price
	entities.add_child(d)
	d.update()
#	d.global_position = camera.position - get_viewport_rect().size/2 +  msg["pos"] 
	d.set_owner(entities)
	d.start()
	
func add_connection(t, msg):
	var c:Connection = msg["connection"]
	entities.add_child(c)
	c.set_owner(entities)

func _draw():
	return
	for p in g.packet_nav.get_points():
		var pos = g.packet_nav.get_point_position(p)
		draw_circle(to_local(Vector2(pos.x, pos.y)), 10, Color.gold)
		for c in g.packet_nav.get_point_connections(p):
			var opos = g.packet_nav.get_point_position(c)
			draw_line(to_local(Vector2(pos.x, pos.y)), to_local(Vector2(opos.x, opos.y)), Color.gold, 2, true)

func _save(file="user://save.json"):	
	var data = {}
	data["version"] = 3
	data["site_name"] = self.site_name
	data["hostname_counter"] = g.hostname_counter
	data["entities"] = []
	
	for entity in entities.get_children():
		if !entity.has_method("save"):
			continue
		var entity_data = entity.save()
		if !entity_data:
			continue
		data["entities"].append({
			"filename": entity.filename,
			"name": entity.name.replace("@", "-"),
			"pos_x": entity.position.x,
			"pos_y": entity.position.y,
			"entity_data": entity_data
			})
	
	var save_game:File = File.new()
	
	save_game.open(file, File.WRITE)
	save_game.store_line(to_json(data))
	var err =  save_game.get_error()
	if err:
		md.emit_message(g.ERROR, {"error": "file error %s while saving %s" % [err, save_game.get_path_absolute()]})
	save_game.close()
	
	
		
		
func _load_save(file="user://save.json"):	
	reset()	
	# wait for children to be freed
	yield(get_tree(), "idle_frame")
	
	var save_game = File.new()
	if not save_game.file_exists(file):
		md.emit_message(g.ERROR, {"error": "file %s not found" % file})
		return false
	save_game.open(file, File.READ)

	var data:Dictionary = parse_json(save_game.get_as_text())
	if data == null:
		md.emit_message(g.ERROR, {"error": "unable to parse %s" % file})
		return false
	
	var v = data["version"]
	if  v != 3:
		md.emit_message(g.ERROR, {"error": "unknown version %s in %s" % [v,file]})
		return false
	
	self.site_name = data["site_name"]
	md.emit_message(g.SITE_NAME_CHANGE, {"name": self.site_name})
	g.hostname_counter = data["hostname_counter"]
	for ed in data["entities"]:
		var e = load(ed["filename"]).instance()
		e.position = Vector2(ed["pos_x"], ed["pos_y"])
		entities.add_child(e)
		e.set_name(ed["name"])
		if ed["name"] != e.get_name():
			md.emit_message(g.ERROR, {"error": "unable to set correct entity_name %s" % ed["name"]})
			return false
		e.load_from_save(ed["entity_data"])
		
		if e.has_method("start"):
			e.start()
		
		
	save_game.close()

	