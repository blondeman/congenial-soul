extends Node

@export var menu: CanvasLayer
@export var game: Node3D

var is_in_game: bool = false

func transition_to_game():
	menu.visible = false
	game.visible = true
	is_in_game = true


func transition_to_menu():
	menu.visible = true
	#game.visible = false
	is_in_game = false
