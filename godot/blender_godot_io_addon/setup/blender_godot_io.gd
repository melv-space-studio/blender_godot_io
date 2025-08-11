@tool
extends EditorPlugin

var dock: Node

func _enter_tree():
	# Setup project settings
	BlenderGodotIOSettings.init_configuration_path()

	# Register extensions
	var config = BlenderGodotIOConfiguration.get_current_config()
	if config:
		config.register()


func _exit_tree():
	# Unregister extensions
	var config = BlenderGodotIOConfiguration.get_current_config()
	if config:
		config.unregister()
