extends Node2D

var NaubScene = preload("res://ingame/Naub.tscn")


func spawn_some():
	# get_tree().paused = not get_tree().paused
	
	var naub1: Naub = NaubScene.instance()
	var naub2: Naub = NaubScene.instance()
	
	var radius_sum = naub1.radius + naub2.radius
	var r = get_viewport_rect().size.x
	var pos = Vector2(r / 2, 0).rotated(TAU * randf())
	var off = Vector2(radius_sum * 1.7 / 2, 0).rotated(TAU * randf())
	naub1.global_position = pos + off
	naub2.global_position = pos - off
	
	naub1.modulate = get_random_color()
	naub2.modulate = get_random_color()
	
	add_child(naub1)
	add_child(naub2)
	Global.emit_naub_naub_contact(naub1, naub2)


func clear():
	for naub in get_tree().get_nodes_in_group("Naub"):
		(naub as Node).queue_free()


func toggle_autopilot(enabled):
	$Autopilot.enabled = enabled


func toggle_autospawn(enabled):
	autospawn_enabled = enabled


func get_random_color() -> Color:
	var colors = [Color.red, Color.green, Color.blue, Color.aqua, Color.yellow, Color.fuchsia]
	colors = [Color8(229, 53, 23), Color8(151, 190, 13), Color8(0, 139, 208), Color8(255, 204, 0), Color8(226, 0, 122), Color8(100, 31, 128), Color8(41, 14, 3)]
	return colors[randi() % len(colors)]


var autospawn_enabled = false

func _on_AutospawnTimer_timeout():
	if autospawn_enabled:
		spawn_some()


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
		


