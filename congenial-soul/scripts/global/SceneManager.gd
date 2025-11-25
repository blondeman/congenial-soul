extends Node

@export var menu: CanvasLayer
@export var game: Node3D

func transition_to_game():
	menu.visible = false
	game.visible = true


func transition_to_menu():
	menu.visible = true
	#game.visible = false
