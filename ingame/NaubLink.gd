class_name NaubLink
extends DampedSpringJoint2D

var line_width = Global.NAUB_LINK_LINE_WIDTH

onready var line = $black
var wanted_distance = Global.NAUB_LINK_WANTED_DISTANCE

func attach_to_naubs(active_naub: Naub, other_naub: Naub):
	var pos_a = active_naub.global_position
	var pos_b = other_naub.global_position
	var distance = pos_a.distance_to(pos_b)
	length = distance
	rest_length = wanted_distance
	
	$black.set_point_position(1, Vector2(0, length))
	$red.set_point_position(1, Vector2(0, length))
	
	active_naub.get_parent().add_child(self)
	active_naub.linked_naubs.append(other_naub)
	other_naub.linked_naubs.append(active_naub)	
	active_naub.links.append(self)
	other_naub.links.append(self)
	
	global_position = active_naub.global_position
	rotation = pos_a.angle_to_point(pos_b) + 0.25 * TAU
	node_a = active_naub.get_path()
	node_b = other_naub.get_path()


func _process(delta):
	var a = get_node(node_a) as Naub
	var b = get_node(node_b) as Naub
	if not is_instance_valid(a) or not is_instance_valid(b):
		return queue_free()
	var distance = a.global_position.distance_to(b.global_position)
	line.set_point_position(0, to_local(a.global_position))
	line.set_point_position(1, to_local(b.global_position))
	var d = clamp(wanted_distance / distance, 0.1, 1.5) if distance else 0
	line.width = line_width * d * min(a.scale.x, b.scale.x)


func _exit_tree():
	var a = get_node(node_a)
	var b = get_node(node_b)
	if is_instance_valid(a) and a is Naub:
		a = a as Naub
		a.links.erase(self)
		a.linked_naubs.erase(b)
	if is_instance_valid(b) and b is Naub:
		b = b as Naub
		b.links.erase(self)
		b.linked_naubs.erase(a)
