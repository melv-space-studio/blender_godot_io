@tool
class_name ReplaceParent extends NodeModifier


func _should_process(node: Node):
	var extras = _get_extras(node)
	var replace_parent = extras.get("replace_parent", false)
	if not replace_parent:
		return false

	if node.get_parent() == null or node.get_parent().owner == null:
		push_warning("Cant replace root node of scene for now")
		return false

	return replace_parent


func _process(node: Node) -> Node:
	var parent = node.get_parent()
	
	var parent_position: Vector3 = Vector3.ZERO
	var parent_quaternion: Quaternion = Quaternion.IDENTITY
	var parent_rotation: Vector3 = Vector3.ZERO
	var parent_scale: Vector3 = Vector3.ONE
	if parent is Node3D:
		parent_position = parent.position
		parent_rotation = parent.rotation
		parent_scale = parent.scale
	
	var owner = parent.owner
	node.owner = null
	
	parent.remove_child(node)
	parent.replace_by(node)
	parent.free()
	
	node.owner = owner
	
	if node is Node3D:
		node.position = parent_position + (parent_quaternion * node.position * parent_scale)
		node.quaternion = parent_quaternion + node.quaternion
		node.scale = parent_scale * node.scale
	
	return node
