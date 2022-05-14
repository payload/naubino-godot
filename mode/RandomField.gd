extends Node2D


var NaubScene = preload("res://ingame/Naub.tscn")


var palette1 = {
	"r": Color8(229, 53, 23),
	"g": Color8(151, 190, 13), 
	"b": Color8(0, 139, 208),
	"y": Color8(255, 204, 0),
	"p": Color8(226, 0, 122),
	"l": Color8(100, 31, 128),
	"black": Color8(41, 14, 3),
}


func get_random_color() -> Color:
	var colors = [Color.red, Color.green, Color.blue,
		Color.aqua, Color.yellow, Color.fuchsia]
	colors = [Color8(229, 53, 23), Color8(151, 190, 13), Color8(0, 139, 208), Color8(255, 204, 0), Color8(226, 0, 122), Color8(100, 31, 128), Color8(41, 14, 3)]
	return colors[randi() % len(colors)]


func _ready():
	randomize()
	spawn_some_chain()

func spawn_some_chain():
	var naub_distance = Global.NAUB_LINK_WANTED_DISTANCE
	var normal = clock(randi())
	var tangent = normal + PI/2
	var init_pos = polar(200, normal)
	var node_offset = polar(naub_distance, tangent)
	var chain_offset = polar(naub_distance, normal)
	var chains = spawn_chains("r.g.b.1:black.y.p.l", init_pos, node_offset, chain_offset)


func polar(length, angle):
	return Vector2(length, 0).rotated(angle)


func clock(hour: int):
	return TAU * ((hour % 12) / 12.0)


func spawn_chains(def: String, init_pos: Vector2, node_offset: Vector2, chain_offset: Vector2):
	var named_nodes = {}
	var node_chains = []
	
	var chains = def.split(" ", false)
	for chain in chains:
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
				# assert(not (new_name in named_nodes))
				spec = split[1]
			else:
				spec = desc
				
			assert(spec)
			if spec.is_valid_integer():
				assert(!new_name)
				if spec in named_nodes:
					next_node = named_nodes[spec]
				else:
					next_node = NaubScene.instance()
					add_child(next_node)
					named_nodes[spec] = next_node
			else:
				if new_name in named_nodes:
					next_node = named_nodes[new_name]
				else:
					next_node = NaubScene.instance()
					add_child(next_node)
					if new_name:
						named_nodes[new_name] = next_node
				nodes.push_back(next_node)
				
				assert(spec in palette1)
				color = palette1[spec]
				next_node.modulate = color
				
			if current_node:
				link_together(current_node, next_node)
			current_node = next_node
		node_chains.push_back(nodes)
	
	for chain_index in len(node_chains):
		var chain = node_chains[chain_index]
		var chain_pos = init_pos + chain_offset * (chain_index - len(node_chains) / 2)
		var mid = len(chain) / 2
		for index in len(chain):
			var node = chain[index]
			var factor = index - mid
			node.position = chain_pos + node_offset * factor
	
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
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_SPACE):
			spawn_some_chain()
	
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
		
