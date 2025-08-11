## Extends GLTFDocumentExtension to provide custom processing for Blender workflow glTF imports
## This class handles additional metadata and node processing for glTF files exported from Blender
@tool 
class_name BlenderWorkflowGLTFExtension extends GLTFDocumentExtension

const CUSTOM_DATA = &"blender_godot_io_addon"

@export
var enabled: bool = true

@export
var modifiers: Array[NodeModifier] = []


func _import_preflight(state: GLTFState, _extensions):
	return ERR_SKIP


func _import_node(state: GLTFState, _gltf_node: GLTFNode, json: Dictionary, node: Node) -> Error:
	if "-skip" in state.filename:
		return OK
	
	var data = state.get_additional_data(CUSTOM_DATA)
	
	if json.has("extras"):
		var to_store = {node.name: json.extras}
		if data:
			data.merge(to_store)
		else:
			data = to_store

		state.set_additional_data(CUSTOM_DATA, data)
		node.set_meta("extras", json.extras)

	return OK


func _import_post(state: GLTFState, root: Node) -> Error:
	if "-skip" in state.filename:
		return OK

	var extras = state.get_additional_data(CUSTOM_DATA)
	if extras == null:
		extras = {}

	var result = _process(root, extras)
	return OK


## Recursively processes a node and its children, applying custom processing based on extras metadata
## Traverses the node hierarchy, potentially replacing nodes with processed versions
## 
## @param node The current node being processed
## @param extras A dictionary of all metadata from the original glTF import keyed by node names
## @return The processed node (which may be the original or a replacement)
func _process(node: Node, extras: Dictionary) -> Node:
	var node_extras = node.get_meta("extras", {})
	
	for child in node.get_children():
		if is_instance_valid(child):
			_process(child, extras)

	if modifiers:
		for modifier in modifiers:
			if not node or not is_instance_valid(node):
				break

			# TODO(@melvspace): 2025/05/31 check leaf is [@tool] script
			if modifier.should_process(node):
				node = modifier.process(node)

	return node
