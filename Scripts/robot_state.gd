extends Node
class_name RobotState

var robot_state_machine : RobtoStateMachine = null
var robot : Robot

func _ready():
	await owner.ready


func handled_input(event : InputEvent):
	pass
	
func update(_delta : float) -> void:
	pass

func physics_update(_delta : float) -> void:
	pass

func enter():
	pass

func exit():
	pass
