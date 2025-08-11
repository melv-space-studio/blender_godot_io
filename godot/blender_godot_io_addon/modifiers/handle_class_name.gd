## Represents a node type change modifier that can transform nodes between compatible types
## during a GLTF processing operation.
@tool
class_name HandleClassName extends NodeModifier

@export
var blacklist: Array[String] = []


func _should_process(node: Node):
	var extras = _get_extras(node)
	var classname = extras.get("class_name")
	
	if classname:
		return (ClassDB.class_exists(classname) and classname not in blacklist)

	return false


func _process(node: Node) -> Node:
	var extras = _get_extras(node)
	var classname = extras.get("class_name")
	
	var new_node = ClassDB.instantiate(classname)
	new_node.name = node.name
	
	if node is Node3D:
		if new_node is Node3D:
			new_node.transform = node.transform

	for meta_item in node.get_meta_list():
		new_node.set_meta(meta_item, node.get_meta(meta_item))

	node.replace_by(new_node, true)
	new_node = _handle_special_types(node, new_node)
	
	node.free()

	return new_node
	
func _handle_special_types(original_node: Node, next_node: Node) -> Node:
	var apply_params = ApplyParams.new()
	
	if next_node is ReflectionProbe:
		if original_node is not ImporterMeshInstance3D:
			push_warning("Unable to create reflection probe from not mesh node")
			return next_node
		
		original_node = original_node as ImporterMeshInstance3D
		next_node = next_node as ReflectionProbe
	
		if apply_params.should_process(next_node):
			next_node = apply_params.process(next_node)
		
		var aabb = original_node.mesh.get_mesh().get_aabb()
		next_node.size = aabb.size + Vector3.ONE * next_node.blend_distance * 2

	if next_node is CollisionShape3D:
		if original_node is not ImporterMeshInstance3D:
			push_warning("Unable to create collision node from not mesh node")
			
		original_node = original_node as ImporterMeshInstance3D
		next_node = next_node as CollisionShape3D
		
		var shape = CollisionShapeUtility.create_convex_shape_from_array_mesh(original_node.mesh.get_mesh())
		next_node.shape = shape
		return next_node
		
	return next_node
			
