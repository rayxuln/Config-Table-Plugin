extends Node


func _ready() -> void:
	var data := ConfigHelper.item.by_id(2)
	print("物品： %s, 价格: %.2f" % [data.name, data.cost])
