@tool
class_name NodeModifier extends Resource

@export
var enabled: bool = true

## virtual
func _should_process(node: Node):
	return false

## Check if the node should be processed by this leaf
## 
## @param name: The name of the node
## @return: True if the node should be processed, False otherwise
func should_process(node: Node):
	return enabled and _should_process(node)


## virtual
func _process(node: Node) -> Node:
	return node
	

## Process the node with the given extras
## 
## @param node: The node to process
## @return: The processed node
func process(node: Node) -> Node:
	if not enabled:
		return node

	return _process(node)


func _log(message):
	var script = get_script();
	var script_name = (get_script() as GDScript).get_global_name() if script else "NodeModifier"
	print("[%s]: %s" % [script_name, message])


func _get_extras(node: Node) -> Dictionary:
	return node.get_meta("extras", {})

	
func _write_extras(node: Node, key: String, value: Variant):
	var dict = _get_extras(node)
	dict.set(key, value)
	node.set_meta("extras", dict)


## Replaces a node with a new node, transferring all children and preserving the original node's name
## 
## @param node The original node to be replaced
## @param new_node The new node that will replace the original node
## @private
func _replace_node(node: Node, new_node: Node, extras = null, skip_children: bool = true):
	if not skip_children:
		for child in node.get_children(true):
			child.set_owner(null)
			node.remove_child(child)
			new_node.add_child(child, Node.INTERNAL_MODE_BACK)
			child.set_owner(node.get_owner())
	
	node.add_sibling(new_node)

	var node_name: String = node.name
	var node_owner: Node = node.get_owner()
	var node_meta = extras if extras else node.get_meta("extras", {})
	
	if node is Node3D:
		if new_node is Node3D:
			new_node.transform = node.transform
	
	node.free()

	new_node.owner = node_owner
	new_node.name = node_name
	new_node.set_meta("extras", node_meta)
