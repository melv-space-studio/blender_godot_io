@tool
class_name ChangeRigidbodyGIMode extends NodeModifier


func _should_process(node: Node):
	return node is RigidBody3D


func _process(node: Node) -> Node:
	_process_meshes(node)
	return node


func _process_meshes(node: Node):
	if node is MeshInstance3D or node is ImporterMeshInstance3D:
		BlenderNodes.new().apply_param(node, 'gi_mode', MeshInstance3D.GI_MODE_DYNAMIC)
		
	for child in node.get_children():
		_process_meshes(child)
