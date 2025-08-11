## Removes redundant nodes in hierarchy
## 
## ! Will break animations
@tool
class_name SimplifyHierarchy extends NodeModifier

func _should_process(node: Node):
	if not node.owner:
		return false

	var is_simple_node = node.get_class() == "Node3D"
	if not is_simple_node:
		return false

	if node.get_children().size() == 1:
		var child = node.get_child(0)
		if child is Node3D:
			return true
		
	return false


func _process(node: Node) -> Node:
	node = node as Node3D
	var node_name = node.name
	var child = node.get_child(0) as Node3D
	var transform = node.transform
	
	print("Will replace %s with %s" % [node, child])
	
	child.owner = null
	child.transform = transform * child.transform
	
	node.remove_child(child)
	node.replace_by(child)
	node.free()
	
	child.name = node_name
	
	return child
