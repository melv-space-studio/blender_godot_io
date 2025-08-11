@tool
class_name ApplyParams extends NodeModifier


func _should_process(node: Node):
	var extras = _get_extras(node)
	return not extras.is_empty();


func _process(node: Node) -> Node:
	var extras = _get_extras(node)
		
	for key in extras.keys():
		BlenderNodes.new().apply_param(node, key, extras[key])

	return node
