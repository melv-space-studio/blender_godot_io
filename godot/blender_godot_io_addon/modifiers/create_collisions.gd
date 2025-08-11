@tool
class_name CreateCollisions extends NodeModifier


func _should_process(node: Node):
	var extras = _get_extras(node)
	var collision = extras.get('collision')

	return node is PhysicsBody3D and collision != null
	

func _process(node: Node) -> Node:
	var extras = _get_extras(node)
	var collision = extras['collision']
	
	return _collisions(node, collision, extras)


## Generates a collision body for a given node based on metadata
## 
## Supports creating different types of collision bodies (StaticBody3D, RigidBody3D, Area3D, etc.)
## with various shape types (box, cylinder, sphere, capsule) and collision generation modes.
## 
## @param node The source node to create a collision body for
## @param collision Metadata string defining collision body type and properties
## @param extras Dictionary containing additional configuration details
## @return Node The generated collision body or modified original node
func _collisions(node: PhysicsBody3D, collision: String, extras: Dictionary) -> Node:
	var target_mesh: String = extras.get('mesh', "")
	var t = node.transform
	
	var simple: bool = "simple" in collision
	var trimesh: bool = "trimesh" in collision
	
	# try to generate trimesh (concave) or simple (convex) collisions
	var trimesh_shape := ConcavePolygonShape3D.new()
	var simple_shape := ConvexPolygonShape3D.new()

	var mesh_instance: ImporterMeshInstance3D
	if target_mesh:
		print(target_mesh)
		mesh_instance = node.get_node(target_mesh)
		print("Mesh instance found: ", mesh_instance)

	else:
		print("Searching for mesh instance...")
		mesh_instance = _find_mesh_instance(node)
		print("Mesh instance found: ", mesh_instance)

	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D_" + node.name
	
	var col_only = "-c" in collision
	collision_shape.scale = node.scale
	collision_shape.rotation = node.rotation

	if simple or trimesh:
		push_warning("Trimesh and Simple mesh collisions are unimplemented")
		return node
		
		if not mesh_instance:
			push_warning("No mesh instance found, cannot create convex collision")
			return node

		var collision_shapes = _get_mesh_collisions(mesh_instance, not simple)
		if collision_shapes.size() > 0:
			collision_shape.shape = collision_shapes[0]
	
	if not simple and not trimesh:
		if "center_x" in extras and "center_y" in extras and "center_z" in extras:
			var center_x = float(extras.get("center_x"))
			var center_y = float(extras.get("center_y"))
			var center_z = - float(extras.get("center_z"))
			collision_shape.position += Vector3(center_x, center_y, center_z)
	
	if "box" in collision:
		if "size_x" in extras and "size_x" in extras \
		and "size_z" in extras:
			var box = BoxShape3D.new()
			
			var size_x = float(extras.get("size_x"))
			var size_y = float(extras.get("size_y"))
			var size_z = float(extras.get("size_z"))
			
			box.size = Vector3(size_x, size_y, size_z)
			
			collision_shape.shape = box
	
	if "cylinder" in collision:
		if "height" in extras and "radius" in extras:
			var cylinder = CylinderShape3D.new()
			
			var height = float(extras.get("height"))
			var radius = float(extras.get("radius"))
			
			cylinder.height = height
			cylinder.radius = radius
			
			collision_shape.shape = cylinder
	
	if "sphere" in collision:
		if "radius" in extras:
			var sphere = SphereShape3D.new()
			var radius = float(extras.get("radius"))

			sphere.radius = radius
			collision_shape.shape = sphere
	
	if "capsule" in collision:
		if "height" in extras and "radius" in extras:
			var capsule = CapsuleShape3D.new()
			
			var height = float(extras.get("height"))
			var radius = float(extras.get("radius"))
			
			capsule.height = height
			capsule.radius = radius
			
			collision_shape.shape = capsule
	
	if collision_shape.shape == null:
		push_warning("No collision shape found, cannot create collision")
		return node
	
	if col_only and mesh_instance:
		mesh_instance.free()
		
	node.add_child(collision_shape)
	collision_shape.owner = node.owner

	return node
	

## Recursively searches for the first MeshInstance3D child within a given node and its descendants
## 
## @param node: The starting node to search for a MeshInstance3D
## @return MeshInstance3D: The first MeshInstance3D found, or null if no MeshInstance3D exists
func _find_mesh_instance(node: Node) -> ImporterMeshInstance3D:
	for child in node.get_children():
		if child is ImporterMeshInstance3D:
			return child

		return _find_mesh_instance(child)

	return null


func _get_mesh_collisions(node: ImporterMeshInstance3D, include_convex: bool) -> Array[Shape3D]:
	var r_collision_map: Dictionary = {}
	var collisions: Array[CollisionShape3D] = []
	var mesh = node.mesh
	var shapes: Array[Shape3D] = []

	if r_collision_map.has(mesh):
		shapes = r_collision_map[mesh]
	else:
		shapes = _pre_gen_shape_list(mesh, include_convex)
		r_collision_map[mesh] = shapes
	
	return shapes
 
 
func _pre_gen_shape_list(mesh: ImporterMesh, p_convex: bool) -> Array[Shape3D]:
	if !p_convex:
		var shape: ConcavePolygonShape3D = mesh.create_trimesh_shape()
		return [shape]

	else:
		var shapes = []
		shapes.push_back(mesh.create_convex_shape(true,  false))
		return shapes
