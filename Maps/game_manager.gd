extends Node2D

@onready var tilemap_01 : TileMap = $"../TileMap"
@onready var grids : Node2D = $Grids
@onready var cursor : CharacterBody2D = $Cursor
@onready var robots : Node2D = $Robots

# 关卡场景的节点
@onready var map_node : Node2D = $".."
# 单元格大小
const grid_size : Vector2i = Vector2i(16, 16)
# 首个格子位置
const start_position : Vector2i = Vector2i(8, 8)
# 洪水算法中计算格子四个方向单位距离的格子位置
const offerset = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0)]


# 地图格子集合
var map_dict : Dictionary

var grid_resource : Resource = preload("res://Prefabs/grid.tscn")
var robot_resource : Resource = preload("res://Prefabs/robot.tscn")
# 获取tilemap矩阵的位置坐标、矩阵大小，从而获得格子起始点坐标、格子总数
@onready var tilemap_rect : Rect2i = tilemap_01.get_used_rect()

var astar_grid_2d : AStarGrid2D

func _ready():
	#print_debug(Input.get_joy_info(0))
	print_debug(tilemap_01.get_used_rect())
	print_debug(tilemap_01.get_used_rect().position)
	print_debug(tilemap_01.get_used_rect().size)
	print_debug(cursor.position)
	init()

func _input(event):
	move_coursor()
	# 输入映射中设置的死区、get_vector()中设置的四区好像不会生效，同样的值用get_joy_axis()限制后，能够解决摇杆漂移问题
	#var vel = Input.get_vector("left", "right", "up", "down", 0.9)
	#print_debug("vel:",vel)
	#var current_tile :Vector2i = tilemap_01.local_to_map(coursor.position)
	#var target_position = Vector2i(current_tile.x + vel.x, current_tile.y + vel.y)
	#print_debug("target_position:",target_position)
	#coursor.position = tilemap_01.map_to_local(target_position)

# 光标移动
func move_coursor():
	# 获取移动光标在tilemap矩阵中的坐标
	var current_tile = tilemap_01.local_to_map(cursor.position)
	var move_x : int = 0
	var move_y : int = 0
	
	if Input.is_action_pressed("up") || Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) < -0.5:
		# 限制光标移动范围
		if current_tile.y == tilemap_rect.position.y:
			return
		else :
			move_y -= grid_size.y
	if Input.is_action_pressed("down") || Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) > 0.5:
		# 算出矩阵中位置最远的的位置的坐标-1
		if current_tile.y == tilemap_rect.size.y + tilemap_rect.position.y - 1:
			return
		else :
			move_y += grid_size.y
	if Input.is_action_pressed("left") || Input.get_joy_axis(0, JOY_AXIS_LEFT_X) < -0.5:
		if current_tile.x == tilemap_rect.position.x:
			return
		else :
			move_x -= grid_size.x
	if Input.is_action_pressed("right") || Input.get_joy_axis(0, JOY_AXIS_LEFT_X) > 0.5:
		if current_tile.x == tilemap_rect.size.x + tilemap_rect.position.x - 1:
			return
		else :
			move_x += grid_size.x
	
	
	
	# 手柄移动，十字键和摇杆，第一个参数为0，不知道原因，但只有为0才能生效
	# 手柄十字键执行命令时，没有回声事件，所以不支持长按，需要使用Input.parse_input_input()来人为触发
	#if Input.is_joy_button_pressed(0, JoyButton.JOY_BUTTON_DPAD_UP) || Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) < -0.5:
		#coursor.position.y -= grid_size.y
	#if Input.is_joy_button_pressed(0, JoyButton.JOY_BUTTON_DPAD_DOWN) || Input.get_joy_axis(0, JOY_AXIS_LEFT_Y) > 0.5:
		#coursor.position.y += grid_size.y
	#if Input.is_joy_button_pressed(0, JoyButton.JOY_BUTTON_DPAD_LEFT) || Input.get_joy_axis(0, JOY_AXIS_LEFT_X) < -0.5:
		#coursor.position.x -= grid_size.x
	#if Input.is_joy_button_pressed(0, JoyButton.JOY_BUTTON_DPAD_RIGHT) || Input.get_joy_axis(0, JOY_AXIS_LEFT_X) > 0.5:
		#coursor.position.x += grid_size.x

	# 手柄左摇杆移动命令
	#print_debug("JOY_AXIS_LEFT_X:", Input.get_joy_axis(0, JOY_AXIS_LEFT_X))
	#print_debug("JOY_AXIS_LEFT_Y:", Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
	#print_debug("JOY_AXIS_RIGHT_X:", Input.get_joy_axis(0, JOY_AXIS_RIGHT_X))
	#print_debug("JOY_AXIS_RIGHT_Y:", Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	
	cursor.position = Vector2(cursor.position.x + move_x, cursor.position.y + move_y)
	# 使光标移动变得平滑，动画时间不宜设置过长，容易造成位置偏差
	#create_tween().tween_property(coursor, "position", Vector2(coursor.position.x + move_x, coursor.position.y + move_y), 0.01).set_trans(Tween.TRANS_LINEAR)

# 初始化地图
func init():
	for i in range(tilemap_rect.position.x, tilemap_rect.size.x):
		for j in range(tilemap_rect.position.y, tilemap_rect.size.y):
			# 在每个地图格子上实例化Grid结点，即给每个格子上盖上Area2d
			var grid = grid_resource.instantiate()
			grid.grid_index = Vector2i(i, j)
			var pos_x = i * grid_size.x + start_position.x
			var pos_y = j * grid_size.y + start_position.y
			grid.position = Vector2i(pos_x, pos_y)
			#tilemap_01.map_to_local(grid.position)
			grid.name = String.num(tilemap_01.local_to_map(grid.position).x) + "," + String.num(tilemap_01.local_to_map(grid.position).y)
			grids.add_child(grid)
			map_dict[grid.grid_index] = grid
		#
	# 初始化移动范围、攻击范围的sprite2d，设为不显示
	for i in map_dict.keys():
		map_dict[i].range.visible = false
		map_dict[i].att_range.visible = false

	# 访问json中棋子信息
	var map_name = map_node.name
	var json_path = "res://Data/" + map_name + ".json"
	var json_data = Util.load_json_file(json_path)
	var robots_data : Dictionary = json_data.robot
	# print_debug(robot_data)
	for key in robots_data.keys():
		var robot_data = robots_data[key]
		var robot = robot_resource.instantiate()
		set_robot_property(robot, robot_data)
		
	
	# 初始化AStart2D
	astar_grid_2d = AStarGrid2D.new()
	astar_grid_2d.region = tilemap_rect
	astar_grid_2d.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid_2d.cell_size = grid_size
	astar_grid_2d.update()

# 实例化棋子
func set_robot_property(robot : Robot, robot_data):
	robot.connect("robot_command", Callable(self, "_on_robot_command"))
	
	robot.r_id = robot_data.r_id
	robot.r_name = robot_data.r_name
	robot.move_distance = robot_data.move_distance
	robot.move_type = robot_data.move_type
	robot.grid_index = Vector2i(robot_data.x, robot_data.y)
	robot.r_team = robot_data.r_team
	robot.att_distance = robot_data.att_distance
	robot.att_spacing = robot_data.att_spacing
	# 配置中的坐标乘以格子大小再加上偏移量，就是map中棋子位置
	robot.position = Vector2(robot_data.x * 16 + 8, robot_data.y * 16 + 8)
	robot.name = robot.r_name
	if robot.r_team == 0:
		Current.friend_dict[robot] = robot.grid_index
	elif robot.r_team == 1:
		Current.enemy_dict[robot] = robot.grid_index
	robots.add_child(robot)

# 接收robot.gd发送来的信号，并调用指定函数
func _on_robot_command(command_name):
	print_debug("信号指向函数：", command_name)
	call(command_name)
	
# 显示移动范围、攻击范围
func show_mvoe_range():
	print_debug(Current.robot.r_name,"，位置：",Current.robot.grid_index,"，显示移动范围")
	var robot : Robot = Current.robot
	var move_range_remainder_cost_N_cost : Dictionary = find_move_range(robot)
	var m_range : Array
	#Current.move_range = find_move_range(robot, move_range_remainder_cost)
	
	for i in move_range_remainder_cost_N_cost["move_range_remainder_cost"].keys():
		m_range.append(i)
	Current.move_range = m_range
	# 展示移动范围的sprite2d
	for i in m_range:
		map_dict[i].range.visible = true
	print_debug("Current.move_range:",m_range)
	
	#await get_tree().create_timer(1.0).timeout
	
	Current.att_range = find_att_range(robot, m_range)
	print_debug("Current.att_range:",Current.att_range)
	# 展示攻击范围的sprite2d
	for i in Current.att_range:
		map_dict[i].att_range.visible = true
	
# 计算移动范围，洪水算法填充移动范围
func find_move_range(robot : Robot):
	var move_range : Array # 移动范围
	var move_range_remainder_cost : Dictionary # 移动范围内格子、格子内移动力剩余量 {格子坐标：移动力剩余}
	var move_range_cost : Dictionary # 移动范围内格子、格子内移动力需求量 {格子坐标：移动力需求量}
	var now_position : Dictionary # 每次循环开始时，位于已计算的最边缘的格子，循环结尾处清空再赋值 {格子坐标：移动力剩余}
	var target : Dictionary # 用于now_position清空时，传递参数
	var move_distance : int = robot.move_distance # 移动力
	var move_type = robot.move_type # 移动类型，不同类型在地图格子上的移动力消耗不同
	var grid_index = robot.grid_index # 棋子坐标
	#print_debug("move distance:", move_distance)
	now_position[robot.grid_index] = move_distance
	# 遍历移动力次数
	for i in range(move_distance):
		# 遍历边缘格子，不断获取邻居格子，直到移动力消耗完，铺成移动范围
		for now_key in now_position.keys():
			var neighbours : Dictionary = find_neighbours_grid(now_key, "move")
			#print_debug("neighbours:",neighbours)
			if neighbours != null:
				for key in neighbours.keys():
					#tilemap的自定义数据，如果是围墙则排除，并计算移动力消耗
					if neighbours[key].get_custom_data("wall"):
						continue
					var move_cost = neighbours[key].get_custom_data("move_cost")[move_type]
					#print_debug("nowkey:",now_position)
					#if move_distance >= move_cost:
					var remainder_cost = now_position[now_key] - move_cost
					
					# 如果move_range_remainder_cost中存在了neighbours中的格子，则判断此格子上棋子的移动力剩余，留下0以上剩余最多的
					if move_range_remainder_cost == null:
						#move_range_remainder_cost[key] = neighbours[key]
						#target[key] = neighbours[key]
						move_range_remainder_cost[key] = remainder_cost
						target[key] = remainder_cost
						move_range_cost[key] = move_cost
					if move_range_remainder_cost != null:
						if move_range_remainder_cost.keys().has(key):
							if move_range_remainder_cost[key] <= remainder_cost and remainder_cost >= 0:
								#move_range_remainder_cost[key] = neighbours[key]
								#target[key] = neighbours[key]
								move_range_remainder_cost[key] = remainder_cost
								target[key] = remainder_cost
								move_range_cost[key] = move_cost
								#print_debug("has key:",key,",move_range_remainder_cost:",move_range_remainder_cost[key],",neighbours:",neighbours[key])
						else :
							#move_range_remainder_cost[key] = neighbours[key]
							#target[key] = neighbours[key]
							move_range_remainder_cost[key] = remainder_cost
							target[key] = remainder_cost
							move_range_cost[key] = move_cost
							#print_debug("not has key:",key,",move_range_remainder_cost:",move_range_remainder_cost[key],",neighbours:",neighbours[key])
					#move_range.append(key)
		#if i == move_distance - 1:
		#print_debug("i = ",i,",move_range target:",target)
		now_position.clear()
		if target.is_empty():
			break
		now_position = target.duplicate(true)
		target.clear()
	
	# 移除棋子自身位置
	move_range_remainder_cost.erase(grid_index)
	move_range_cost.erase(grid_index)
	# 筛选出格子上移动力剩余大于等于0的格子，添加到move_range中
	for i in move_range_remainder_cost.keys():
		if move_range_remainder_cost[i] < 0:
			#move_range.append(i)
			move_range_remainder_cost.erase(i)
			move_range_cost.erase(i)
	#move_range = move_range_remainder_cost.keys()
	
	var move_range_remainder_cost_N_cost : Dictionary = {"move_range_remainder_cost":move_range_remainder_cost,"move_range_cost":move_range_cost}
	print_debug("grid_index:",grid_index,",move_range_remainder_cost_N_cost:",move_range_remainder_cost_N_cost)
	return move_range_remainder_cost_N_cost

# 计算攻击范围，获得移动范围的邻居点，不存在move_range中，则列为攻击范围
func find_att_range(robot : Robot, move_range : Array):
	## 存储移动范围边缘格子坐标
	#var move_range_edge : Array
	## {移动范围：剩余移动力}
	#var move_range_remainder_cost : Dictionary = move_range_remainder_cost_N_cost["move_range_remainder_cost"]
	## {移动范围：需求移动力}
	#var move_range_cost : Dictionary = move_range_remainder_cost_N_cost["move_range_cost"]
	# 存储攻击范围
	var att_range : Array
	# 存储攻击间隔范围
	var spacing_range : Array
	# 攻击范围等于移动距离+攻击距离
	var att_distance : int = robot.att_distance
	var att_spacing : int = robot.att_spacing
	var now : Array
	#if move_range == null:
		#now.append(robot.grid_index)
	#else :
	move_range.append(robot.grid_index)
	now = move_range
	#now_position[robot.grid_index] = att_distance
	var target : Array
	# 移动力剩余小于前往下一个格子的移动力需求，即移动范围边缘，没想到好的计算下个格子的方法，暂时放弃
	#for i in move_range_remainder_cost.keys():
		#if move_range_cost[i] > move_range_remainder_cost[i]:
			#move_range_edge.append(i)
	#print_debug("move_range_cost",move_range_cost)
	#print_debug("move_range_remainder_cost:",move_range_remainder_cost)
	#print_debug("move_range_edge:",move_range_edge)
	# 每个移动范围格子遍历攻击距离次数，取得每个格子的邻居点，如果邻居点不存在移动范围中，则加入攻击范围
	for i in range(att_distance):
		for now_key in now:
			#print_debug("now_key-----------:",now_key)
			var neighbours : Dictionary = find_neighbours_grid(now_key, "att")
			if neighbours != null:
				for key in neighbours.keys():
					if !move_range.has(key) and !att_range.has(key):
						# 位于攻击间隔之外
						#if i > att_spacing - 1:
						att_range.append(key)
						target.append(key)
		#
		#print_debug("---i = ",i,",now:",now)
		#print_debug("--i = ",i,",target:",target)
		#print_debug("-i = ",i,",att_range:",att_range)
		if i <= att_spacing:
			#print_debug("i = ",i,",spacing_range:",now)
			spacing_range.append_array(now)
		
		
		#print_debug("Current.move_range+-+-+-+-+4:",Current.move_range)
		## 这里调用now.clear()，会把Current.move_range给清空，godot的bug？
		## 遍历now，输出的结果只有一半，也是godot bug？
		#print_debug("now2:",now)
		##now.clear()
		##for j in now:
			##print_debug("j:",j)
			##now.erase(j)
		#print_debug("now3:",now)
		#print_debug("Current.move_range+-+-+-+-+5:",Current.move_range)
		
		if target.is_empty():
			break
		now = target.duplicate(true)
		target.clear()
	att_range.erase(robot.grid_index)
	
	# 移除攻击范围中的间隔区域
	for i in spacing_range:
		if att_range.has(i):
			att_range.erase(i)
	
	print_debug("att_range:",att_range)
	return att_range
	
# 计算邻居格子，并记录格子属性
# 如果是计算移动范围，find_type输入move，会将友军、敌军所在位置排除
# 如果计算攻击范围，find_type输入att，会将友军、敌军位置计算在内
func find_neighbours_grid(now_key : Vector2i, find_type : String = "move"):
	
	#print_debug("Current.enemy_dict：",Current.enemy_dict)
	#print_debug("Current.friend_dict:",Current.friend_dict)
	var neighours : Dictionary # [key = 邻居坐标： value = 在此格子上的自定义属性（是否为墙、移动所需消耗）]
	
	for i in offerset:
		var vector = now_key + i
		# 将移动范围限制在tilemap内
		if vector.x >= tilemap_rect.position.x and vector.x <= (tilemap_rect.size.x + tilemap_rect.position.x -1) and vector.y >= tilemap_rect.position.y and vector.y <= (tilemap_rect.size.y + tilemap_rect.position.y - 1):
			# 判断此范围在tilemap格子矩阵中
			if map_dict.has(vector):
				if find_type == "move":
					# 将敌军、友军所在位置排除在外
					if Current.enemy_dict.values().has(vector):
						#if Current.enemy_dict[vector].r_team != robot.r_team:
						continue
					elif Current.friend_dict.values().has(vector):
						#if Current.friend_dict[vector].r_team != robot.r_team:
						continue
				
				## 获取tilemap的自定义数据
				var tile_data : TileData = tilemap_01.get_cell_tile_data(0, vector)
				#if tile_data.get_custom_data("wall"):
					#continue
				#var move_cost = tile_data.get_custom_data("move_cost")[move_type]
				##if move_distance >= move_cost:
				#var remainder_cost = move_distance - move_cost
				#neighours[vector] = remainder_cost
				neighours[vector] = tile_data
	
	#print_debug(now_key,"--neighours:",neighours)
	return neighours

# 移动棋子
func robot_move():
	# 是否在移动中
	if Current.id_path.size() > 0:
		return
	var robot : Robot = Current.robot
	var target_tile : Vector2i = tilemap_01.local_to_map(cursor.position)
	# 目标位置不在移动范围中，或者目标位置是友军、敌军所在位置，则不予移动
	if !Current.move_range.has(target_tile) or Current.friend_dict.values().has(target_tile) or Current.enemy_dict.values().has(target_tile):
		return
	
	# 将各个棋子所在的位置设置为不可通行的障碍-------------移动完成应将移动后的棋子起始位置重新添加到寻路列表中
	for i in Current.friend_dict.values():
		astar_grid_2d.set_point_solid(i, true)
	for i in Current.enemy_dict.values():
		astar_grid_2d.set_point_solid(i, true)
	
	Current.id_path = astar_grid_2d.get_id_path(robot.grid_index, target_tile)
	#print_debug("前+++",robot.r_name,"位置：",robot.grid_index,"。目标位置：",target_tile,',移动路线：',Current.id_path)
	
	astar_grid_2d.set_point_solid(robot.grid_index, false)
	# 重置棋子移动后的坐标
	robot.grid_index = Current.id_path[-1]
	if Current.friend_dict.keys().has(robot):
		Current.friend_dict[robot] = robot.grid_index
	if Current.enemy_dict.keys().has(robot):
		Current.enemy_dict[robot] = robot.grid_index
	#print_debug("后---",robot.r_name,"位置：",robot.grid_index,',移动路线：',Current.id_path)

# 隐藏移动范围
func hidden_mvoe_range():
	for i in Current.move_range:
		map_dict[i].range.visible = false
	Current.move_range.clear()

# 隐藏攻击范围
func hidden_att_range():
	for i in Current.att_range:
		map_dict[i].att_range.visible = false
	Current.att_range.clear()
