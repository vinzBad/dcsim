tool
extends Node

var port = preload("res://nodes/bits/port/port.tscn")
var connection = preload("res://nodes/bits/connection/connection.tscn")
var server = preload("res://nodes/devices/server/server.tscn")
var router = preload("res://nodes/devices/router/router.tscn")
var uplink = preload("res://nodes/devices/uplink/uplink.tscn")
var packet = preload("res://nodes/bits/packet/packet.tscn")

var grid_size = 10

var NEEDS_PORT_CLICK = "NEEDS_PORT_CLICK"
var NEEDS_DEVICE_CLICK = "NEEDS_DEVICE_CLICK"

func ridify(vec:Vector2, align:Vector2=Vector2.INF):
	if vec.x != align.x:
		vec.x = int(vec.x / grid_size) * grid_size
	if vec.y !=align.y:
		vec.y = int(vec.y / grid_size) * grid_size
		
	return vec


	
var packet_nav:AStar = AStar.new()

var uid2device  = {}
var _last_uid = 0

func get_uid():
	_last_uid += 1
	return _last_uid
