@tool
class_name ReuseTextures extends NodeModifier

@export_dir
var textures_path: String = ""

func _should_process(node: Node):
	return node is ImporterMeshInstance3D


func _process(node: Node) -> Node:
	if not textures_path:
		push_warning("Textures Path not set.")
		return node
	
	if node is ImporterMeshInstance3D:
		var surface_count = node.mesh.get_surface_count()
		for i in surface_count:
			var material = node.mesh.get_surface_material(i)
			if material is StandardMaterial3D:
				var albedo_texture = material.albedo_texture
				var normal_texture = material.normal_texture
				var emission_texture = material.emission_texture
				var roughness_texture = material.roughness_texture
				var metallic_texture = material.metallic_texture
				var ao_texture = material.ao_texture
				var rim_texture = material.rim_texture
				var orm_texture = material.orm_texture
				var backlight_texture = material.backlight_texture
				var clearcoat_texture = material.clearcoat_texture
				var heightmap_texture = material.heightmap_texture
				var refraction_texture = material.refraction_texture
				var subsurf_scatter_texture = material.subsurf_scatter_texture

	return node
