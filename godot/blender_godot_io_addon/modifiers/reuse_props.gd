@tool
class_name ReuseProps extends NodeModifier

@export_dir
var props_path: String = ""

@export
var force_override: bool = false


func _should_process(node: Node):
	return node.name.begins_with("P_")


func _process(node: Node) -> Node:
	if not props_path:
		push_warning("Props Path not set.")
		return node
		
	var scene_name = node.name.substr(2)
	var regex = RegEx.new()
	regex.compile("_\\d+$")
	scene_name = regex.sub(scene_name, "", true)
	
	for prop_name in ResourceLoader.list_directory(props_path):
		if prop_name.begins_with(scene_name):
			var path = "%s/%s" % [props_path, prop_name]
			var new_node = Node3D.new()
			node.add_child(new_node)
			new_node.owner = node.owner
			_write_extras(new_node, "packed_scene", path)
			return new_node
	
	return node
	
