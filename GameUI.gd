extends CanvasLayer

signal toggle_autospawn(enabled)
signal toggle_emojis(enabled)
signal toggle_autopilot(enabled)
signal spawn_some()
signal clear()

func _ready():
	$VBoxContainer/AutospawnButton.connect("toggled", self, "_on_toggled", ["toggle_autospawn"])
	$VBoxContainer/EmojiButton.connect("toggled", self, "_on_toggled", ["toggle_emojis"])
	$VBoxContainer/AutopilotButton.connect("toggled", self, "_on_toggled", ["toggle_autopilot"])
	$VBoxContainer/SpawnButton.connect("pressed", self, "_on_pressed", ["spawn_some"])
	$VBoxContainer/ClearButton.connect("pressed", self, "_on_pressed", ["clear"])

func _on_toggled(enabled: bool, my_signal: String):
	emit_signal(my_signal, enabled)

func _on_pressed(my_signal: String):
	emit_signal(my_signal)
