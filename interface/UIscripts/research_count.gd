extends Control
@onready var label: RichTextLabel = $PanelContainer/RichTextLabel

func _process(_delta: float) -> void:
	var total: float = 0.0
	for planet in get_tree().get_nodes_in_group("planets"):
		total += planet.totalResearch
	label.text = "Total Research:\n[color=teal]%s[/color]" % int(total)
