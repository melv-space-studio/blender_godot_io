@tool
class_name HandleAttachScript extends NodeModifier

func _should_process(node: Node):
	var script = get_script_name(node)
	if not script:
		return false
	
	return find_script(script) != null


func _process(node: Node) -> Node:
	var script_name = get_script_name(node)
	var script_data = find_script(script_name)
	var path = script_data.get('path')
	var script = load(path)
	
	print("attaching script %s to %s" % [script, node.name])
	
	node.set_script(script)
	
	return node


func get_script_name(node: Node):
	var extras = _get_extras(node)
	var classname = extras.get("class_name")
	var script = extras.get("attach_script")
	
	if not script and classname:
		if ClassDB.class_exists(classname):
			return null

		script = classname
	
	return script


func find_script(name: StringName):
	var target_class = null
	for class_item in ProjectSettings.get_global_class_list():
		if class_item.get("class") == name:
			target_class = class_item
		
	return target_class
