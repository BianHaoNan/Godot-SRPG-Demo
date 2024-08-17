extends Node


func load_json_file(path : String):
	if FileAccess.file_exists(path):
		var file_data = FileAccess.open(path, FileAccess.READ).get_as_text()
		var dict = JSON.parse_string(file_data)
		if dict is Dictionary:
			return dict
		else :
			print_debug("文件读取错误：", dict)
	else :
		print_debug("未找到文件：", path)
