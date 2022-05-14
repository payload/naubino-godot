extends Node2D


func _ready():
	randomize()
	spawn_chains("y.y", Vector2.ZERO, 0)
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

func _spawn_chains(def: String, pos: Vector2, node_offset: Vector2, chain_offset: Vector2):
	var interpreter = ChainsInterpreter.new(self)
	for chain in def.split(" ", false):
		for desc in chain.split(".", false):
			if desc.find(":") > -1:
				var split = desc.split(":")
				assert(len(split) == 2)
				interpreter.named_node_with_spec(split[0], split[1])
			elif desc.is_valid_integer():
				interpreter.reference_node(desc)
			else:
				interpreter.node_with_spec(desc)	
		interpreter.end_chain()
	var chains = interpreter.get_chains()
	_modify_positions_to_centered(chains, pos, node_offset, chain_offset)
	return chains


class ChainsInterpreter:
	var _named_nodes = {}
	var _chains = []
	var _nodes = []
	var _current_node = null
	var _parent: Node

	func _init(parent: Node):
		_parent = parent

	func get_chains():
		return _chains

	func end_chain():
		if not _nodes.empty():
			_chains.push_back(_nodes)
			_nodes = []

	func named_node_with_spec(name: String, spec: String):
		assert(name.is_valid_integer() and not spec.is_valid_integer())
		var node = _get_or_create_named_node(name)
		_apply_spec(node, spec)
		_link_and_set_current_node(node)
	
	func reference_node(name: String):
		var node = _get_or_create_named_node(name)
		_link_and_set_current_node(node)
	
	func node_with_spec(spec: String):
		var node = _spawn_naub()
		_apply_spec(node, spec)
		_link_and_set_current_node(node)

	func _get_or_create_named_node(name: String):
		if not (name in _named_nodes):
			_named_nodes[name] = _spawn_naub()
		return _named_nodes[name]

	func _link_and_set_current_node(node: Naub):
		if _current_node:
			Global.link_two_naubs_together(_current_node, node)
		_parent.add_child(node)
		_current_node = node
	
	func _apply_spec(naub: Naub, spec: String):
		assert(spec in Global.NAUBINO_PALETTE)
		naub.modulate = Global.NAUBINO_PALETTE[spec]
	
	func _spawn_naub():
		var naub = Global.NaubScene.instance()
		_parent.add_child(naub)
		_nodes.push_back(naub)
		return naub


func _modify_positions_to_centered(node_chains: Array, pos: Vector2, node_offset: Vector2, chain_offset: Vector2):
	for chain_index in len(node_chains):
		var chain = node_chains[chain_index]
		var chain_pos = pos + chain_offset * (chain_index - len(node_chains) / 2)
		var mid = (len(chain) - 1) / 2.0
		for index in len(chain):
			var node = chain[index]
			var factor = index - mid
			node.position = chain_pos + node_offset * factor


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
