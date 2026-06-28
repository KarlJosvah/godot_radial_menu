@tool
extends EditorPlugin

const RadialMenuScript: Script = preload("res://addons/radial_menu/radial_menu.gd")
const RadialMenuIcon: Texture2D = preload("res://addons/radial_menu/icon.svg")

func _enter_tree() -> void:
	# Register the custom type so it shows up in the "Create New Node" dialog
	add_custom_type(
		"RadialMenu",
		"Control",
		RadialMenuScript,
		RadialMenuIcon
	)

func _exit_tree() -> void:
	# Always clean up your custom types when disabling the plugin
	remove_custom_type("RadialMenu")
