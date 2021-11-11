extends Node


func _ready() -> void:
	print(ConfigHelper.people_people.by_name('张三1').age)
