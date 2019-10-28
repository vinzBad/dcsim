extends Node2D
class_name SimWorld

export var camera_path:NodePath
onready var camera:Camera2D = get_node(camera_path)

var site_name = "l33t.io"

onready var entities = $entities

var cashflow_samples = [0,0,0,0, 0, 0, 0, 0, 0]
var last_money = 0

func _ready():
	last_money = g.money
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
	var packets = get_tree().get_nodes_in_group(g.PACKET)
	
	
	g.money -= len(uplinks) * g.defs["uplink"]["price"]["pertick"]
	g.money -= len(routers) * g.defs["router"]["price"]["pertick"]
	g.money -= len(switches) * g.defs["switch"]["price"]["pertick"]
	g.money -= len(servers) * g.defs["server"]["price"]["pertick"]
	
	for server in servers:
		var service = server.get_service()
		if service == null:
			continue
		if service.in_use:
			if randf() < 0.25 and service.is_up(uplinks):
				gen_packet(service)
		elif g.queue > 0 and randf() > 0.8 and service.is_up(uplinks):
			g.queue -= 1
			service.go_live()
			service.update()
	if g.queue == 0 and randf() < 0.1:
		g.queue += 1
	
	get_tree().call_group(g.PACKET, "next", msg["speed"])
	
	cashflow_samples.pop_front()
	cashflow_samples.push_back(g.money - last_money)
	g.cashflow = 0
	for sample in cashflow_samples:
		g.cashflow += sample
	
	g.cashflow = stepify(g.cashflow/float(len(cashflow_samples)), 0.01)
	
	last_money = g.money
	
	
func gen_packet(service):
	var p = g.packet.instance()
	entities.add_child(p)
	p.start(service.uplink, service.port)
	

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

func _save(file="user://save.json"):	
	var data = {}
	data["version"] = 3
	data["site_name"] = self.site_name
	data["hostname_counter"] = g.hostname_counter
	data["entities"] = []
	data["money"] = g.money
	
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
	
	g.money = data.get("money", 333)
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

	