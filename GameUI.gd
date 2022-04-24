extends CanvasLayer

signal toggle_autospawn(enabled)
signal toggle_emojis(enabled)
signal toggle_autopilot(enabled)
signal spawn_some()
signal clear()

func _ready():
	var _x
	_x = $VBoxContainer/AutospawnButton.connect("toggled", self, "emit_toggle_autospawn")
	_x = $VBoxContainer/EmojiButton.connect("toggled", self, "emit_toggle_emojis")
	_x = $VBoxContainer/AutopilotButton.connect("toggled", self, "emit_toggle_autopilot")
	_x = $VBoxContainer/SpawnButton.connect("pressed", self, "emit_spawn_some")
	_x = $VBoxContainer/ClearButton.connect("pressed", self, "emit_clear")

func emit_toggle_autospawn(enabled): emit_signal("toggle_autospawn", enabled)
func emit_toggle_emojis(enabled): emit_signal("toggle_emojis", enabled)
func emit_toggle_autopilot(enabled): emit_signal("toggle_autopilot", enabled)
func emit_spawn_some(): emit_signal("spawn_some")
func emit_clear(): emit_signal("clear")
