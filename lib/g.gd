extends Node

## Colors
var green = Color("#20C20E")

## Group Names
const NEED_UPDATE_COLORSCHEME = "NEED_UPDATE_COLORSCHEME"

## Message Names
const ERROR = "ERROR"
const TICK = "TICK"
const LOAD = "LOAD"
const SAVE = "SAVE"
const RESET = "RESET"
const SITE_NAME_CHANGE = "SITE_NAME_CHANGE"
const SET_CAMERA = "SET_CAMERA"
const ADD_DEVICE = "ADD_DEVICE"
const ADD_CONNECTION = "ADD_CONNECTION"
const SELECT_DEVICE = "SELECT_DEVICE"
const SELECT_PORT = "SELECT_PORT"
const PORT_STATUS = "PORT_STATUS"
const CONN_STATUS = "CONN_STATUS"
const MOVE_DEVICE = "MOVE_DEVICE"
const REMOVE_DEVICE = "REMOVE_DEVICE"

## Preloads
var device = preload("res://nodes/devices/device.tscn")
var port = preload("res://nodes/bits/port/port.tscn")
var connection = preload("res://nodes/bits/connection/connection.tscn")
var server = preload("res://nodes/devices/server/server.tscn")
var router = preload("res://nodes/devices/router/router.tscn")
var uplink = preload("res://nodes/devices/uplink/uplink.tscn")
var packet = preload("res://nodes/bits/packet/packet.tscn")


## Constants
var unit_height = 30
var unit_width = 150
var grid_size = 10

## Group Names
const NEEDS_PORT_CLICK = "NEEDS_PORT_CLICK"
const NEEDS_DEVICE_CLICK = "NEEDS_DEVICE_CLICK"

var selected_device:Device = null

func ridify(vec:Vector2, align:Vector2=Vector2.INF):
	if vec.x != align.x:
		vec.x = int(vec.x / grid_size) * grid_size
	if vec.y !=align.y:
		vec.y = int(vec.y / grid_size) * grid_size
		
	return vec

## NAV 
var packet_nav:AStar = AStar.new()
var uid2device:Dictionary  = {}
var _last_uid:int = 0

func get_uid():
	_last_uid += 1
	return _last_uid
	
func reset(t=null, msg=null):
	packet_nav = AStar.new()
	uid2device  = {}
	_last_uid = 0
	defs = {}
	hostname_counter = {}
	hostname2device = {}
	load_defs()
	load_colors("default.json")

## DEFs

var defs = {}
var hostname_counter = {}
var hostname2device = {}
var _port_registry = {}
var colorscheme = {}

func _ready():
	md.connect_message(g.RESET, self, "reset")
	yield(get_tree(), "idle_frame")
	reset()

func load_colors(name):
	var def_file = File.new()
	def_file.open("res://content/colorschemes/"+ name, File.READ)
	var def = parse_json(def_file.get_as_text())
	def_file.close()
	colorscheme = def
	
func register_port(device:Device, port:Port):
	assert(port != null)
	assert(device != null)
	_port_registry[[device.hostname, port.port_name]] = port

func find_port(hostname, port_name):
	return _port_registry.get([hostname, port_name])

func load_defs():
	var dir = Directory.new()
	var def_root = "res://content/defs/"
	if dir.open(def_root) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if !dir.current_is_dir() and file_name.ends_with(".json"):
				load_def_from_file(def_root + file_name)
			file_name = dir.get_next()
	
func load_def_from_file(file):
	var def_file = File.new()
	def_file.open(file, File.READ)
	var def = parse_json(def_file.get_as_text())
	def_file.close()
	defs[def["device_type"]] = def
	hostname_counter[def["device_type"]] = 0
	
func get_hostname(def):
	var hostname = def["hostname_format"] % hostname_counter[def["device_type"]]
	hostname_counter[def["device_type"]] += 1
	return hostname
	
