extends RobotState

# 信号指向robot.gd
signal show_move_range
signal robot_move
signal hidden_move_range
signal hidden_att_range

func enter():
	#print_debug(owner.r_name,"进入移动状态")
	#show_move_range.emit()
	#Current.robot.r_state = "Move"
	emit_signal("show_move_range")
 
func handled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		#print_debug('移动指令')
		emit_signal("robot_move")

func update(_delta : float) -> void:
	# 向目标移动
	var current_id_path = Current.id_path
	if current_id_path.is_empty():
		return
	var target_tile = current_id_path.front()
	var target_tile_position = Vector2(target_tile.x * 16 + 8, target_tile.y * 16 + 8)
	owner.position = owner.position.move_toward(target_tile_position, 4)
	if owner.global_position == target_tile_position:
		current_id_path.pop_front()
		if current_id_path.is_empty():
			Current.id_path.clear()
			robot_state_machine.transition_to("end")

func exit():
	#print_debug(owner.r_name,"离开移动状态")
	#show_move_range.emit()
	emit_signal("hidden_move_range")
	emit_signal("hidden_att_range")
