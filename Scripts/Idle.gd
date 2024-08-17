extends RobotState



func enter():
	#print_debug(owner.name,"进入空闲")
	#robot.r_state = 'Idle'
	#print_debug(robot)
	pass

func handled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		#emit_signal("robot_command", "show_mvoe_range")
		#robot_command.emit("show_mvoe_range")
		robot_state_machine.transition_to("Move")
