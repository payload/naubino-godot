extends Node


func _physics_process(delta):
	for node in get_tree().get_nodes_in_group("Naub"):
		var naub: Naub = node
		var pos = naub.global_position
		# naub.apply_central_impulse(-0.01 * pos * pos * delta)
