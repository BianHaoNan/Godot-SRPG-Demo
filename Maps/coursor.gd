extends CharacterBody2D

# 相机脚本

@onready var tilemap = $"../../TileMap"
@onready var camera_2d = $Camera2D

const grid_size : Vector2i = Vector2i(16, 16)

func _ready():
	# 获取tilemap矩阵的位置坐标、矩阵大小
	var map_rect : Rect2i = tilemap.get_used_rect()
	# 分别计算镜头在四个方向上的位置极限
	camera_2d.limit_left = map_rect.position.x * grid_size.x
	camera_2d.limit_right = map_rect.position.x * grid_size.x + map_rect.size.x * grid_size.x
	camera_2d.limit_top = map_rect.position.y * grid_size.y
	camera_2d.limit_bottom = map_rect.position.y * grid_size.y + map_rect.size.y * grid_size.y
