extends Node


signal naub_naub_contact(active_naub, other_naub)
signal naub_enter_tree(naub)

var NaubLinkScene = preload("res://NaubLink.tscn")


func _ready():
	connect("naub_naub_contact", self, "on_naub_naub_contact")


func on_naub_naub_contact(active_naub: Naub, other_naub: Naub):
	if active_naub.no_links() or other_naub.no_links():
		link_two_naubs_together(active_naub, other_naub)
	elif active_naub.modulate == other_naub.modulate and not are_neighbors(active_naub, other_naub):
		merge_two_naubs_to_one(active_naub, other_naub)
		find_and_pop_some_cycle(active_naub, other_naub)


func link_two_naubs_together(active_naub: Naub, other_naub: Naub):
	active_naub.linked_naubs.append(other_naub)
	other_naub.linked_naubs.append(active_naub)	
	var link: NaubLink = NaubLinkScene.instance()
	link.attach_to_naubs(active_naub, other_naub)


func merge_two_naubs_to_one(active_naub: Naub, other_naub: Naub):
	for naub in other_naub.linked_naubs:
		link_two_naubs_together(active_naub, naub)
	other_naub.free()


func find_and_pop_some_cycle(active_naub: Naub, other_naub: Naub):
	var cycle = find_cycle(active_naub, other_naub)
	if cycle:
		for c in cycle:
			# colors for debugging, when you see red, something is wrong
			if c.modulate == Color.green:
				c.modulate = Color.red
			else:
				c.modulate = Color.green
			c.pop_away()


func are_neighbors(naub_a, naub_b):
	for naub_x in naub_a.linked_naubs:
		if naub_x == naub_b or naub_x.linked_naubs.has(naub_b):
			return true
	return false


func find_cycle(a: Naub, b: Naub):
	var parents = { a: null }
	var unexplored = [ a ]
	while not unexplored.empty():		
		var c = unexplored.pop_back()
		var p = parents[c]
		var nexts = c.linked_naubs.duplicate()
		nexts.invert()
		for x in nexts:
			if x == p: continue
			if parents.has(x):
				# found a cycle, now fill an array with the nodes backwards the parent-reference
				var cycle = []
				cycle.append(x)
				while c:
					cycle.append(c)
					c = parents[c]
				return cycle
			parents[x] = c
			unexplored.append(x)
	return null
