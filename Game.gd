extends Node2D

var NaubScene = preload("res://Naub.tscn")

func _unhandled_input(event):
	if Input.is_action_just_pressed("spawn_random"):
		var naub1: Naub = NaubScene.instance()
		var naub2: Naub = NaubScene.instance()
		
		var r = get_viewport_rect().size.x * 0.2
		var pos = Vector2(r * sqrt(randf()), 0).rotated(TAU * randf())
		var off = Vector2(20, 0).rotated(TAU * randf())
		naub1.global_position = pos + off
		naub2.global_position = pos - off
		
		add_child(naub1)
		add_child(naub2)
		Global.emit_signal("naub_naub_contact", naub1, naub2)
