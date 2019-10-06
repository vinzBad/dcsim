tool
extends Node

var port = preload("res://nodes/bits/port/port.tscn")
var connection = preload("res://nodes/bits/connection/connection.tscn")
var server = preload("res://nodes/devices/server/server.tscn")
var router = preload("res://nodes/devices/router/router.tscn")

var grid_size = 24

var NEEDS_PORT_CLICK = "NEEDS_PORT_CLICK"

func gridify(vec:Vector2):
	vec.x = int(vec.x / grid_size) * grid_size
	vec.y = int(vec.y / grid_size) * grid_size
	return vec
		

