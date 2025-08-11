@tool
class_name SanitizeNames extends NodeModifier


func _should_process(node: Node):
	return true


func _process(node: Node) -> Node:
	var regex = RegEx.new()
	regex.compile("_\\d+$")
	node.name = regex.sub(node.name, "", true)

	return node
