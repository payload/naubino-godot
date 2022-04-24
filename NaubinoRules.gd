extends Node





func _ready():
	var _x = Global.connect("naub_naub_contact", self, "on_naub_naub_contact")


func on_naub_naub_contact(active_naub: Naub, other_naub: Naub):
	if not is_instance_valid(active_naub) or not is_instance_valid(other_naub):
		return
	if active_naub.no_links() or other_naub.no_links():
		Global.link_two_naubs_together(active_naub, other_naub)
	elif active_naub.modulate == other_naub.modulate and not Global.are_neighbors(active_naub, other_naub):
		other_naub.merge_with_and_free_self(active_naub)
		find_and_pop_some_cycle(active_naub)


func find_and_pop_some_cycle(active_naub: Naub):
	var cycle = find_cycle(active_naub)
	if cycle:
		for c in cycle:
			# colors for debugging, when you see red, something is wrong
			if c.modulate == Color.green:
				c.modulate = Color.red
			else:
				c.modulate = Color.green
			c.pop_away()


func find_cycle(a: Naub):
	var parents = { a: null }
	var unexplored = [ a ]
	while not unexplored.empty():		
		var c = unexplored.pop_back()
		if not is_instance_valid(c):
			continue
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
