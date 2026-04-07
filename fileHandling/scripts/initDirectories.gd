extends Node

var userDirList = [
	"saves"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for dir in userDirList:
		var userDir: String = "user://" + dir
		createAbsentUserDir(userDir)

func createAbsentUserDir(userDir: String) -> void:
	if not DirAccess.dir_exists_absolute(userDir):
		var error = DirAccess.make_dir_recursive_absolute(userDir)
		if error != OK:
			push_error("Failed to create directory. Error code: ", error)
