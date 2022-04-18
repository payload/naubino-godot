class_name Naub
extends RigidBody2D


var active = false
var follow_mouse = false
var mouse_hovering = false
export(Array) var linked_naubs: Array
export(Array) var links: Array
var radius = 10


func set_active(active = true):
	self.active = active


func follow_position(global: Vector2, speed: float):
	var v = global - global_position
	var d = v.length_squared()
	var n = v.normalized()
	linear_velocity = n * clamp(d, 0, speed)


func pop_away():
	var tween = Tween.new()
	tween.interpolate_property(self, "scale", self.scale, Vector2.ZERO, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
	tween.connect("tween_all_completed", self, "free")


func merge_with_and_free_self(active_naub: Naub):
	for naub in linked_naubs:
		Global.link_two_naubs_together(active_naub, naub)
	for link in links:
		link.free()
	queue_free()


func no_links():
	return linked_naubs.empty()


func _ready():
	linked_naubs = []
	links = []
	$CollisionShape2D.shape.radius = radius


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if mouse_hovering and Input.is_action_just_pressed("click"):
			active = true
			follow_mouse = true
		elif follow_mouse and Input.is_action_just_released("click"):
			active = false
			follow_mouse = false


func _physics_process(delta):
	if follow_mouse:
		follow_position(get_global_mouse_position(), 1000)


func _enter_tree():
	Global.emit_signal("naub_enter_tree", self)


func _exit_tree():
	linked_naubs.clear()
	var links = self.links
	self.links = []
	for link in links:
		link.free()


func _on_RigidBody2D_mouse_entered():
	mouse_hovering = true


func _on_RigidBody2D_mouse_exited():
	mouse_hovering = false


func _on_RigidBody2D_body_entered(body: CollisionObject2D):
	if active and body.is_in_group("Naub") and not linked_naubs.has(body):
		Global.emit_signal("naub_naub_contact", self, body)
