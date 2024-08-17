extends Node

# 当前选中的棋子
var robot : Robot
# 保存移动路线
var id_path : Array[Vector2i]
# 移动范围
var move_range : Array
# 攻击范围
var att_range : Array
# 友军
var friend_dict : Dictionary # [key:棋子类，value:棋子坐标]
# 敌军
var enemy_dict : Dictionary # [key:棋子类，value:棋子坐标]
