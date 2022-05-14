extends Node


export(bool) var enabled = true


var active_naub: Naub = null
var target_naub: Naub = null


var _touch_id = -1
var _timeout = 6 # you have this much seconds to connect two naubs
var _time = 0


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


func _physics_process(delta):
	if not enabled:
		if is_instance_valid(active_naub):
			active_naub.follow_touch = null
			active_naub = null
			target_naub = null
			Global.touches[_touch_id].pressed = false
		return
	
	if not active_naub or not target_naub:
		var naubs = []
		for naub in get_tree().get_nodes_in_group("Naub"):
			naub = naub as Naub
			if not naub.is_active() and naub.is_on_screen():
				naubs.push_back(naub)
		
		if len(naubs) < 2:
			return
		
		naubs.shuffle()
		active_naub = naubs.pop_back()
		
		var good = []
		for naub in naubs:
			if is_good_target(naub):
				good.push_back(naub)
			
		var best = null
		var best_distance = INF
		for naub in good:
			naub = naub as Naub
			var distance = naub.position.distance_squared_to(active_naub.position)
			if distance < best_distance:
				best = naub
				best_distance = distance
		
		if not best:
			return
		
		target_naub = best
		active_naub.follow_touch = _touch_id
		_time = 0
		
		yield(get_tree().create_timer(_timeout), "timeout")
		
		target_naub = null
	
	if not is_instance_valid(active_naub) or not is_instance_valid(target_naub) or not is_good_target(target_naub):
		if is_instance_valid(active_naub): active_naub.follow_touch = null
		active_naub = null
		target_naub = null
		Global.touches[_touch_id].pressed = false
		return
	
	if active_naub and target_naub:
		_time += delta
		var touch = Global.touches[_touch_id]
		touch.pressed = true
		touch.position = lerp(active_naub.global_position, target_naub.global_position, clamp(_time / _timeout, 0.2, 1.0))
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
