extends Control


func _ready():
	$"start game".connect("pressed", self, "_start_game")

func _start_game():
	match $mode.selected:
		0: get_tree().change_scene("res://mode/Mode1.tscn")
		1: get_tree().change_scene("res://mode/RandomField.tscn")
