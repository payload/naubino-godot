extends Node


signal naub_naub_contact(active_naub, other_naub)
signal naub_enter_tree(naub)


func are_neighbors(naub_a, naub_b):
	for naub_x in naub_a.linked_naubs:
		if naub_x == naub_b or naub_x.linked_naubs.has(naub_b):
			return true
	return false


var NaubLinkScene = preload("res://NaubLink.tscn")
func link_two_naubs_together(active_naub: Naub, other_naub: Naub):
	active_naub.linked_naubs.append(other_naub)
	other_naub.linked_naubs.append(active_naub)	
	var link: NaubLink = NaubLinkScene.instance()
	link.attach_to_naubs(active_naub, other_naub)
