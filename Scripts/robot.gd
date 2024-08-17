extends Node2D

class_name Robot

var r_id : String
var r_name : String
var move_distance : int
var move_type : String
var grid_index : Vector2i
var r_team : int
var r_state : String
var att_distance : int # 攻击距离
var att_spacing : int # 攻击间隔，如：弓箭只能攻击距离2的位置，无法攻击距离1的位置，间隔为1
@onready var sprite_2d = $Sprite2D
@onready var robot_state_mechine : RobtoStateMachine = $Robot_state_machine

signal robot_command

func _ready():
	# 初始化棋子的图片
	var robot_icon_path = "res://RobotsIcons/" + r_id + ".png"
	sprite_2d.texture = load(robot_icon_path)
	#print_debug("robot state machine:",robot_state_mechine.state)

func _on_area_2d_body_entered(body):
	# 光标选中棋子后将Current中的robot指向该选中的棋子
	if Current.robot != self:
		# 如果选中的棋子进入移动状态，则在选中其他棋子时不会更改Current.robot的值
		if Current.robot != null:
			if Current.robot.r_state == "Move":
				print_debug(Current.robot.r_name," -+-+r_state：",Current.robot.r_state)
				#print_debug("选中r self:", self.name)
				return
			
		Current.robot = self
	#print_debug("选中：",Current.robot.r_name) 
	print_debug("选中 self:", self.name)

func _on_area_2d_body_exited(body):
	# 光标离开棋子后，清除Current.robot的值
	if Current.robot == self :
		if Current.robot.r_state == "Move":
			return
		# 如果选中的棋子进入移动状态，则在选中其他棋子时不会更改Current.robot的值
		#if get_robot_state() == "Move":
			#print_debug("离开r：",Current.robot.r_name)
			#print_debug("离开r self:", self.name)
			#return
		
		if get_robot_state() == "Idle" or get_robot_state() == "end":
			Current.robot = null
	#print_debug("离开：",Current.robot.r_name)
	print_debug("离开 self:", self.name)


# 获取棋子状态机当前所处的状态，默认为Idle
func get_robot_state():
	print_debug(robot_state_mechine.state.name)
	return robot_state_mechine.state.name

func set_robot_state(state):
	robot_state_mechine.transition_to(state)

#func _unhandled_input(event):
	#if Current.robot != self:
		#return
	#if event.is_action_pressed("ui_accept"):
		#emit_signal("robot_command", "show_mvoe_range")
		#robot_command.emit("show_mvoe_range")

func _on_move_show_move_range():
	robot_command.emit("show_mvoe_range")

func _on_move_robot_move():
	robot_command.emit("robot_move")

func _on_move_hidden_move_range():
	robot_command.emit("hidden_mvoe_range")


func _on_move_hidden_att_range():
	robot_command.emit("hidden_att_range")
