extends Node2D


func _ready():
	randomize()
	spawn_chains("r.g", Vector2.ZERO, 0)
	for layer in range(1, 6):
		var n = layer * 3
		for angle in n:
			angle = TAU * angle / n
			var pos = _polar(100 * layer, angle)
			spawn_chains(_random_chain(), pos, angle - PI/2)


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


#
# A chains definition looks like so:
# Chains a split by spaces. Nodes linked by dots.
# Nodes are described for example by their color.
#
#  red.green.blue yellow.yellow
#
# So above example are two chains.
# One is a _chain of a red, green and a blue node.
# They are linked in this order, red with green and green with blue.
# The second _chain is a pair of two yellow nodes.
# This way you can create linear chains of nodes.
#
# Note that the color definition is the name of the color
# from your palette. So when in your palette are entries like "r", "g", "b"
# you can define your _chain concisely like so:
#
#  r.g.b
#
# When you want to link multiple nodes to a single node, you can define
# multiple chains and use a number reference to refer to the same node multiple times.
#
#  r.1:g.b   y.1.y
#
# Reference names to nodes are given with a colon (:).
# Chain one is a red (r), green (g) and blue (b) node but the green one has the name 1.
# The second _chain links two yellow nodes to node 1, which is the green node from the other _chain.
#
# You can also refer to nodes which are defined in a later _chain.
#
#  r.1.b  y.1:g.y
#
# This way the green node is position in the second _chain.
#
func spawn_chains(def: String, pos: Vector2, angle: float):
	var node_offset = _polar(Global.NAUB_LINK_WANTED_DISTANCE, angle)
	var chain_offset = _polar(Global.NAUB_LINK_WANTED_DISTANCE, angle - PI/2)
	_spawn_chains(def, pos, node_offset, chain_offset)

func _spawn_chains(def: String, init_pos: Vector2, node_offset: Vector2, chain_offset: Vector2):
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
					next_node = Global.NaubScene.instance()
					add_child(next_node)
					named_nodes[spec] = next_node
			else:
				if new_name in named_nodes:
					next_node = named_nodes[new_name]
				else:
					next_node = Global.NaubScene.instance()
					add_child(next_node)
					if new_name:
						named_nodes[new_name] = next_node
				nodes.push_back(next_node)
				
				assert(spec in Global.NAUBINO_PALETTE)
				color = Global.NAUBINO_PALETTE[spec]
				next_node.modulate = color
				
			if current_node:
				_link_together(current_node, next_node)
			current_node = next_node
		node_chains.push_back(nodes)
	
	for chain_index in len(node_chains):
		var chain = node_chains[chain_index]
		var chain_pos = init_pos + chain_offset * (chain_index - len(node_chains) / 2)
		var mid = (len(chain) - 1) / 2.0
		for index in len(chain):
			var node = chain[index]
			var factor = index - mid
			node.position = chain_pos + node_offset * factor
	
	return node_chains


func _link_together(a: Naub, b: Naub):
	Global.link_two_naubs_together(a, b)


# pick a random color
func r():
	return pick("rrggbby")


func _random_chain():
	if randf() < 0.8:
		return _chain([r(), r(), r()])
	else:
		return _chain([r(), r()])


func _join(arr: Array, with: String):
	var ret = ""
	for i in len(arr) - 1:
		ret += arr[i] + with
	ret += arr[-1]
	return ret


func pick(arr):
	return arr[randi() % len(arr)]


func _chain(specs: Array):
	return _join(specs, ".")

	
func _polar(length, angle):
	return Vector2(length, 0).rotated(angle)
