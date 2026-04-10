class_name Orbital extends Node2D

@onready var sprite : Sprite2D = $Sprite2D

@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var planetParentUid : int = 0
var planetParent : Planet = null # convienient, but not saved
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var theta : float = 0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var omega : float = 1
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var orbitDistance : float = 50

static var skyCity = preload("res://assets/orbitals/SkyCity.png")
static var sRocket = preload("res://assets/orbitals/SRocket.png")
static var mRocket = preload("res://assets/orbitals/MRocket.png")
static var lRocket = preload("res://assets/orbitals/LRocket.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var potentialParent = get_parent()
	if potentialParent is Planet:
		planetParentUid = potentialParent.uid
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not planetParentUid:
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

func setTexture(texture : Texture2D):
	$Sprite2D.texture = texture
