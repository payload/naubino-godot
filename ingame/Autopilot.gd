extends Node


export(bool) var enabled = true


var _active_naub: Naub = null
var _target_naub: Naub = null
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
	if not enabled and _is_hunting():
		_reset()
	elif not _is_hunting():
		_try_start_hunting()
	elif not is_instance_valid(_active_naub) or not is_instance_valid(_target_naub):
		_reset()
	if _is_hunting():
		if _is_good_target(_active_naub, _target_naub):
			_update_hunting(delta)
		else:
			_reset()


func _is_hunting():
	return _active_naub and _target_naub


func _try_start_hunting():
	var naubs = _get_naubs()
	if naubs.empty(): return
	naubs.shuffle()
	var active_naub = naubs.pop_back()
	var good_targets = []
	for naub in naubs:
		if _is_good_target(active_naub, naub):
			good_targets.push_back(naub)

	var nearest_naub = _find_nearest(active_naub.position, good_targets)
	if nearest_naub:
		_start_hunting(active_naub, nearest_naub)


func _get_naubs():
	var naubs = []
	for naub in get_tree().get_nodes_in_group("Naub"):
		naub = naub as Naub
		if not naub.is_active() and naub.is_on_screen():
			naubs.push_back(naub)
	return naubs if len(naubs) >= 2 else []


func _find_nearest(position: Vector2, nodes: Array):
	var best = null
	var best_distance = INF
	for node in nodes:
		node = node as Node2D
		var distance = node.position.distance_squared_to(position)
		if distance < best_distance:
			best = node
			best_distance = distance
	return best


func _start_hunting(active_naub: Naub, target_naub: Naub):
	_active_naub = active_naub
	_target_naub = target_naub
	_time = 0
	active_naub.follow_touch = _touch_id
	yield(get_tree().create_timer(_timeout), "timeout")
	_reset()


func _reset():
	if is_instance_valid(_active_naub): _active_naub.follow_touch = null
	_active_naub = null
	_target_naub = null
	Global.touches[_touch_id].pressed = false


func _update_hunting(delta: float):
	_time += delta
	var touch = Global.touches[_touch_id]
	touch.pressed = true
	touch.position = lerp(_active_naub.global_position, _target_naub.global_position, clamp(_time / _timeout, 0.2, 1.0))
	touch.speed = _target_naub.linear_velocity
	

func _is_good_target(hunter: Naub, target: Naub):
	return is_instance_valid(target) \
		and not target.is_active() \
		and target.is_on_screen() \
		and (target.linked_naubs.empty() \
			or (hunter.modulate == target.modulate
				and not Global.are_neighbors(hunter, target)
			)
		)
