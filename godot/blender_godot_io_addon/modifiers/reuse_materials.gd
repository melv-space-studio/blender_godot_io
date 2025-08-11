@tool
class_name ReuseMaterials extends NodeModifier

@export_dir
var materials_path: String = ""

@export
var force_override: bool = false

@export
var skip_material: Material

func _should_process(node: Node):
	return node is ImporterMeshInstance3D


func _process(node: Node) -> Node:
	if not materials_path:
		push_warning("Materials Path not set.")
		return node
	
	if node is ImporterMeshInstance3D:
		var surface_count = node.mesh.get_surface_count()
		for i in surface_count:
			var material = node.mesh.get_surface_material(i)
			if material.resource_name.begins_with("M_"):
				var material_resource_name = material.resource_name.substr(2)
				var material_path = "%s/%s.tres" % [materials_path, material_resource_name]
				
				if material.resource_name.ends_with('-skip'):
					if not skip_material:
						push_warning("Unable to skip material %s on %s" % [node.name, material.resource_name])
						continue

					node.mesh.set_surface_material(i, skip_material)
					continue
				
				if force_override or not ResourceLoader.exists(material_path):
					material.take_over_path(material_path)
					ResourceSaver.save(material, material_path, ResourceSaver.FLAG_CHANGE_PATH)
				
				node.mesh.set_surface_material(i, load(material_path))

	return node
