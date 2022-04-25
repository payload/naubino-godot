extends Node


export(bool) var enabled = true


var active_naub: Naub = null
var target_naub: Naub = null


var _touch_id = -1


func _ready():
	# allocate fake touch id, negative numbers are free for artificial touches like autopilot
	while Global.touches.has(_touch_id):
		_touch_id -= 1
	Global.touches[_touch_id] = {
		index = _touch_id,
		position = Vector2.ZERO,
		pressed = false,
		speed = Vector2.ZERO,
	}


func _physics_process(_delta):
	if not enabled:
		if is_instance_valid(active_naub):
			active_naub.follow_touch = null
			active_naub = null
			target_naub = null
			Global.touches[_touch_id].pressed = false
		return
	if not active_naub or not target_naub:
		active_naub = null
		target_naub = null
		var naubs = get_tree().get_nodes_in_group("Naub")
		naubs.shuffle()
		while len(naubs) >= 2:
			active_naub = naubs.pop_back() as Naub
			if active_naub.is_active() or active_naub.is_on_screen():
				continue
		if active_naub:
			for naub in naubs:
				if is_good_target(naub):
					target_naub = naub
					active_naub.follow_touch = _touch_id
					yield(get_tree().create_timer(4), "timeout")
					target_naub = null
					return
		return
	
	if not is_instance_valid(active_naub) or not is_instance_valid(target_naub) or not is_good_target(target_naub):
		if is_instance_valid(active_naub): active_naub.follow_touch = null
		active_naub = null
		target_naub = null
		Global.touches[_touch_id].pressed = false
		return
	
	if target_naub:
		var touch = Global.touches[_touch_id]
		touch.pressed = true
		touch.position = target_naub.global_position
		touch.speed = target_naub.linear_velocity
	


func is_good_target(naub: Naub):
	return is_instance_valid(naub) \
		and not naub.is_active() \
		and naub.is_on_screen() \
		and (naub.linked_naubs.empty() \
			or (active_naub.modulate == naub.modulate
				and not Global.are_neighbors(active_naub, naub)
			)
		)
