extends Node


export(bool) var enabled = true


var active_naub: Naub = null
var target_naub: Naub = null


func _physics_process(delta):
	if not enabled: return
	if not active_naub or not target_naub:
		active_naub = null
		target_naub = null
		var naubs = get_tree().get_nodes_in_group("Naub")
		naubs.shuffle()
		while len(naubs) >= 2:
			active_naub = naubs.pop_back() as Naub
			if active_naub.active:
				continue
		if active_naub:
			for naub in naubs:
				if is_good_target(naub):
					target_naub = naub
					active_naub.set_active()
					return
		return
	
	if not is_instance_valid(active_naub) or not is_instance_valid(target_naub) or not is_good_target(target_naub):
		if is_instance_valid(active_naub): active_naub.set_active(false)
		active_naub = null
		target_naub = null
		return
	
	active_naub.follow_position(target_naub.global_position, 500)


func is_good_target(naub: Naub):
	return is_instance_valid(naub) \
		and not naub.active \
		and (naub.linked_naubs.empty() \
			or (active_naub.modulate == naub.modulate
				and not Global.are_neighbors(active_naub, naub)
			)
		)
