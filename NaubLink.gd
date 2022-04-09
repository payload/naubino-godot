class_name NaubLink
extends Node2D

export(float) var line_width = 6

var node_a: Naub = null
var node_b: Naub = null
onready var line = $Line2D
onready var spring = $DampedSpringJoint2D
var factor = 0

func attach_to_naubs(active_naub: Naub, other_naub: Naub):
	var spring = $DampedSpringJoint2D
	remove_child(spring)
	var d = active_naub.global_position.distance_to(other_naub.global_position)
	factor = d
	spring.length = d
	spring.rest_length = d
	spring.node_a = active_naub.get_path()
	spring.node_b = other_naub.get_path()
	active_naub.add_child(self)
	add_child(spring)
	node_a = active_naub
	node_b = other_naub

func _process(delta):
	if not is_instance_valid(node_b): return queue_free()
	var end = to_local(node_b.global_position)
	line.set_point_position(1, end)
	if $DampedSpringJoint2D:
		var d = clamp(factor * 2 / end.length(), 0.5, 1)
		line.width = line_width * d
