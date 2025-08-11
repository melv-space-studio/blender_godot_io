@tool
class_name ReplaceWithPackedScene extends NodeModifier


func _should_process(node: Node):
	var extras = _get_extras(node)
	if extras.has("packed_scene"):
		return true

	return false


func _process(node: Node) -> Node:
	if node.get_parent() == null or node.get_parent().owner == null:
		node.free()
		return null
	
	var parent = node.get_parent()
	
	# Workaround to fix collection instance translation
	var node_position := Vector3.ZERO
	if parent is Node3D:
		print(parent.get_child(0))
		node_position = parent.get_child(0).position
		if parent is Node3D:
			node_position = parent.quaternion * node_position
			
	var extras = _get_extras(node)
	var path = extras.get("packed_scene")
	
	if ResourceLoader.exists(path):
		var new_node: Node = load(path).instantiate()
		new_node.position = parent.position
		
		_transfer_children(node, new_node)
		_replace_node(parent, new_node)
		
		if new_node is Node3D:
			new_node.position += node_position

		return new_node
		
	push_warning("Failed to replace %s with packed scene from %s" % [node.name, path])
	return node


func _transfer_children(from_node: Node, to_node: Node):
	var index = 0;
	for child in from_node.get_children():
		_log(child.name)
		_transfer_children(child, to_node.get_child(index))
		index += 1
		
		
