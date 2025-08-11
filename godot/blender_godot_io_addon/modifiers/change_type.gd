## Represents a node type change modifier that can transform nodes between compatible types
## during a GLTF processing operation.
@tool
class_name ChangeType extends NodeModifier


func _get_class(node: Node):
	var regex = RegEx.new()
	regex.compile("_?\\d+$")
	
	return regex.sub(node.name, "", true)


func _should_process(node: Node):
	if node is MeshInstance3D:
		return false

	# TODO(@melvspace): 03/06/2025 - also check extras for `type` property
	return ClassDB.class_exists(_get_class(node))

func _process(node: Node) -> Node:
	var new_node = ClassDB.instantiate(_get_class(node))
	new_node.name = node.name
	
	if node is Node3D and new_node is Node3D:
		node = node as Node3D
		new_node = new_node as Node3D
		new_node.global_position = node.global_position
		new_node.rotation = node.rotation

	for meta_item in node.get_meta_list():
		new_node.set_meta(meta_item, node.get_meta(meta_item))

	node.replace_by(new_node, true)
	node.free()

	return new_node
