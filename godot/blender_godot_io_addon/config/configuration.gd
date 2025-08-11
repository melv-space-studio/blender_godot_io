@tool
@icon("res://addons/blender_godot_io_addon/logo.svg")
class_name BlenderGodotIOConfiguration extends Resource

# TODO(@melvspace): 2025/05/31 detect changes and re-register extensions

@export_tool_button("Activate this configuration")
var set_as_main_configuration = _set_as_main_configuration

@export_category("Data")
@export
var extensions: Array[GLTFDocumentExtension] = [] :
	set(value):
		if _is_registered:
			_unregister()
			
		extensions = value
		
		if _is_registered:
			_register()
		
var _is_registered: bool = false
var is_active: bool :
	get: return BlenderGodotIOConfiguration.get_current_config() == self

static func get_current_config() -> BlenderGodotIOConfiguration:
	var path = BlenderGodotIOSettings.get_configuration_path()
	if not path: 
		return
		
	var resource = load(path)
	if resource is not BlenderGodotIOConfiguration:
		push_warning("Invalid resource provided in settings")
		push_warning("BlenderGodotIOConfiguration is expected")
		return
		
	return resource

func _register():
	for extension in extensions:
		GLTFDocument.register_gltf_document_extension(extension)

func _unregister():
	for extension in extensions:
		GLTFDocument.unregister_gltf_document_extension(extension)

func register():
	print("Registering %s extensions" % extensions.size())
	_register()
	_is_registered = true
	
func unregister():
	print("Unregistering %s extensions" % extensions.size())
	_unregister()
	_is_registered = false


func _set_as_main_configuration():
	var config = BlenderGodotIOConfiguration.get_current_config()
	if config == self:
		print("This configuration is already active")
		return
	
	if config: config.unregister()
	
	BlenderGodotIOSettings.set_configuration_path(resource_path)

	config = BlenderGodotIOConfiguration.get_current_config()
	if config: config.register()
