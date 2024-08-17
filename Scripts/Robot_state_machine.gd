extends Node2D
class_name RobtoStateMachine

@export var initial_state := NodePath()
@onready var state : RobotState = get_node(initial_state)

func _ready():
	await owner.ready
	for child in get_children():
		if child is RobotState:
			child.robot_state_machine = self
	state.enter()

func _unhandled_input(event : InputEvent) -> void:
	if is_selected_robot():
		state.handled_input(event)

func _process(delta):
	if is_selected_robot():
		state.update(delta)

func _physics_process(delta):
	if is_selected_robot():
		state.physics_update(delta)

func transition_to(target_state_name : String):
	# 判断当前棋子当前状态与即将进入的状态是否一致，不一致则改变当前状态
	print_debug('state:', state.name)
	print_debug('target_state_name:', target_state_name)
	if is_selected_robot():
		if not has_node(target_state_name):
			return
		state.exit()
		#print_debug(target_state_name,":",owner.r_id,"===",Current.robot.r_id)
		if target_state_name == "end":
			target_state_name = "Idle"
		state = get_node(target_state_name)
		state.enter()
		Current.robot.r_state = state.name

func  is_selected_robot():
	if Current.robot != null:
		return Current.robot.r_id == owner.r_id
