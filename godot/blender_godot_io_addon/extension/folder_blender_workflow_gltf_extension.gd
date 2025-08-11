## Extension for filtering GLTF document imports based on a specified folder
## Allows selective import of scenes from a designated directory with optional subfolder support
@tool
class_name FolderBlenderWorkflowGLTFExtension extends BlenderWorkflowGLTFExtension


## Folder to import scenes from, extension will not run on files outside this directory
@export var folders: Array[GLTFTargetFolder] = []


func _import_preflight(state, extensions):
	if not enabled:
		return ERR_SKIP

	for target in folders:
		if target.allow_subfolders:
			if state.base_path.contains(target.folder):
				return OK
		else:
			if state.base_path == target.folder:
				return OK
	
	# No folder matched
	return ERR_SKIP
