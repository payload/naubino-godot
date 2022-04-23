extends TextureButton

func _draw():
	modulate = Color.white if pressed else Color.gray
