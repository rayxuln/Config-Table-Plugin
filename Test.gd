extends Node


func _ready() -> void:
	var data = ConfigHelper.people.by_age(15)
	print(data.name)
	print(data.address)
	print(ConfigHelper.people.by_name("张三").phone)
