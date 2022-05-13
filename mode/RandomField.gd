extends Node2D


var NaubScene = preload("res://Naub.tscn")


var palette1 = {
	"r": Color8(229, 53, 23),
	"g": Color8(151, 190, 13), 
	"b": Color8(0, 139, 208),
	"a": Color8(255, 204, 0),
	"y": Color8(226, 0, 122),
	"l": Color8(100, 31, 128),
	"black": Color8(41, 14, 3),
}


func get_random_color() -> Color:
	var colors = [Color.red, Color.green, Color.blue,
		Color.aqua, Color.yellow, Color.fuchsia]
	colors = [Color8(229, 53, 23), Color8(151, 190, 13), Color8(0, 139, 208), Color8(255, 204, 0), Color8(226, 0, 122), Color8(100, 31, 128), Color8(41, 14, 3)]
	return colors[randi() % len(colors)]


func _ready():
	var init_pos = polar(300, clock(randi()))
	var a = clock(randi())
	var node_offset = polar(60, a)
	var chain_offset = polar(60, a + PI/2)
	spawn_chains("r.g.b.a.y.l.black", init_pos, node_offset, chain_offset)


func polar(length, angle):
	print(angle)
	return Vector2(length, 0).rotated(angle)


func clock(hour: int):
	return TAU * (hour % 12) / 12


func spawn_chains(def: String, init_pos: Vector2, node_offset: Vector2, chain_offset: Vector2):
	var named_nodes = {}
	var node_chains = []
	var chain_pos = init_pos
	
	var chains = def.split(" ", false)
	for chain in chains:
		var pos = chain_pos
		var nodes = []
		var current_node = null
		var descs = chain.split(".", false)
		for desc in descs:
			desc = desc as String
			var new_name = null
			var color = null
			var spec = null
			var next_node = null
			
			var colon = desc.find(":")
			if colon > -1:
				var split = desc.split(":")
				assert(len(split) == 2)
				new_name = split[0]
				assert(new_name)
				assert(not (new_name in named_nodes))
				spec = split[1]
			else:
				spec = desc
				
			assert(spec)
			if spec.is_valid_integer():
				assert(!new_name)
				assert(spec in named_nodes)
				next_node = named_nodes[spec]
			else:
				assert(spec in palette1)
				color = palette1[spec]
				next_node = NaubScene.instance()
				(next_node as Naub).mode = RigidBody2D.MODE_STATIC
				next_node.modulate = color
				add_child(next_node)
				nodes.push_back(next_node)
				next_node.position = pos
				if new_name:
					named_nodes[new_name] = next_node
			if current_node:
				link_together(current_node, next_node)
			current_node = next_node
			pos += node_offset
		node_chains.push_back(nodes)
		chain_pos += chain_offset
	return node_chains


func link_together(a: Naub, b: Naub):
	Global.link_two_naubs_together(a, b)


func spawn_some(distance: float):	
	var naub1: Naub = NaubScene.instance()
	var naub2: Naub = NaubScene.instance()
	
	var radius_sum = naub1.radius + naub2.radius
	var pos = Vector2(distance, 0).rotated(TAU * randf())
	var off = Vector2(radius_sum * 1.7 / 2, 0).rotated(TAU * randf())
	naub1.global_position = pos + off
	naub2.global_position = pos - off
	
	naub1.modulate = get_random_color()
	naub2.modulate = get_random_color()
	
	add_child(naub1)
	add_child(naub2)
	Global.emit_naub_naub_contact(naub1, naub2)



func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		event = make_input_local(event)
		event.position = to_global(event.position)
	
	if event is InputEventScreenTouch:
		Global.touches[event.index] = {
			index = event.index,
			position = event.position,
			pressed = event.pressed,
			speed = Vector2.ZERO,
		}
	elif event is InputEventScreenDrag:
		var touch = Global.touches[event.index]
		touch.position = event.position
		touch.speed = event.speed
	
	if event is InputEventScreenTouch and event.pressed:		
		var space = get_world_2d().direct_space_state
		var hits = space.intersect_point(event.position)
		for hit in hits:
			if hit.collider is Naub:
				(hit.collider as Naub).follow_touch = event.index
		
