class_name Naub
extends RigidBody2D


var follow_mouse = false
var mouse_hovering = false
export(Array) var linked_naubs


func pop_away():
	var tween = Tween.new()
	tween.interpolate_property(self, "scale", self.scale, Vector2.ZERO, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
	tween.connect("tween_all_completed", self, "free")


func _ready():
	linked_naubs = []


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if mouse_hovering and Input.is_action_just_pressed("click"):
			follow_mouse = true
		elif follow_mouse and Input.is_action_just_released("click"):
			follow_mouse = false


func _physics_process(delta):
	if follow_mouse:
		var v = get_global_mouse_position() - global_position
		var d = v.length_squared()
		var n = v.normalized()
		linear_velocity = n * clamp(d, 0, 5000)


func _enter_tree():
	Global.emit_signal("naub_enter_tree", self)


func _exit_tree():
	for naub in linked_naubs:
		if is_instance_valid(naub):
			var index = naub.linked_naubs.find(self)
			naub.linked_naubs.remove(index)


func _on_RigidBody2D_mouse_entered():
	mouse_hovering = true


func _on_RigidBody2D_mouse_exited():
	mouse_hovering = false


func _on_RigidBody2D_body_entered(body: CollisionObject2D):
	if follow_mouse and body.is_in_group("Naub") and not linked_naubs.has(body):
		Global.emit_signal("naub_naub_contact", self, body)
