class_name Orbital extends Node2D


@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var planetParent : Planet = null
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var theta : float = 0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var omega : float = 1
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var orbitDistance : float = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var potentialParent = get_parent()
	if potentialParent is Planet:
		planetParent = potentialParent
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not planetParent:
		return
	theta += omega * delta
	global_position = planetParent.global_position + (orbitDistance * Vector2(sin(theta), cos(theta)))
	global_rotation = 0
	
func toDict():
	var returnDict = {}
	for property in get_property_list():
		if property["hint_string"] == "save" and property["name"] != "planetParent":
			@warning_ignore("shadowed_variable_base_class")
			var name = property["name"]
			returnDict[name] = var_to_str(self.get(name))
	returnDict["type"] = type_string(typeof(self))
	return returnDict

func fromDict(dict : Dictionary):
	for key in dict.keys():
		if key == "type": 
			continue
		set(key, str_to_var(dict[key]))
