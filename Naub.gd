class_name Naub
extends RigidBody2D


export(Array) var linked_naubs: Array
export(Array) var links: Array
var radius = 17
var follow_touch = null


func is_active():
	return follow_touch != null


func pop_away():
	var tween = Tween.new()
	tween.interpolate_property(self, "scale", self.scale, Vector2.ZERO, 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
	tween.connect("tween_all_completed", self, "queue_free")


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
	$MeshInstance2D.mesh.radius = radius
	$MeshInstance2D.mesh.height = radius * 2


func _unhandled_input(event):
	if event is InputEventScreenTouch and not event.pressed and follow_touch == event.index:
		follow_touch = null


func _physics_process(_delta):
	if follow_touch != null:
		var position = Global.touches[follow_touch].position
		if position:
			_follow_position(position, 1000)


func _follow_position(global: Vector2, speed: float):
	var v = global - global_position
	var d = v.length_squared()
	var n = v.normalized()
	linear_velocity = n * clamp(d, 0, speed)


func _enter_tree():
	Global.emit_naub_enter_tree(self)


func _exit_tree():
	linked_naubs.clear()
	var last_links = self.links
	self.links = []
	for link in last_links:
		link.free()


func _on_Naub_body_entered(body: CollisionObject2D):
	if is_active() and body.is_in_group("Naub") and not linked_naubs.has(body):
		Global.emit_naub_naub_contact(self, body)
