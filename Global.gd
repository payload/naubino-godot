extends Node


signal naub_naub_contact(active_naub, other_naub)
signal naub_enter_tree(naub)


func emit_naub_naub_contact(active_naub: Naub, other_naub: Naub):
	emit_signal("naub_naub_contact", active_naub, other_naub)


func emit_naub_enter_tree(naub: Naub):
	emit_signal("naub_enter_tree", naub)


func are_neighbors(naub_a, naub_b):
	for naub_x in naub_a.linked_naubs:
		if is_instance_valid(naub_x) and (naub_x == naub_b or naub_x.linked_naubs.has(naub_b)):
			return true
	return false


var NaubScene = preload("res://ingame/Naub.tscn")
var NaubLinkScene = preload("res://ingame/NaubLink.tscn")


func link_two_naubs_together(active_naub: Naub, other_naub: Naub):
	var link: NaubLink = NaubLinkScene.instance()
	link.attach_to_naubs(active_naub, other_naub)


# index, position, pressed, speed
var touches: Dictionary = {}


var NAUB_RADIUS = 18
var NAUB_LINK_WANTED_DISTANCE = NAUB_RADIUS * 4
var NAUB_LINK_LINE_WIDTH = NAUB_RADIUS / 3

var NAUBINO_PALETTE = {
	"r": Color8(229, 53, 23),
	"g": Color8(151, 190, 13), 
	"b": Color8(0, 139, 208),
	"y": Color8(255, 204, 0),
	"p": Color8(226, 0, 122),
	"l": Color8(100, 31, 128),
	"black": Color8(41, 14, 3),
}
