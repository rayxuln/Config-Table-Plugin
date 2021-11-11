extends ConfigTable

class DataType:
	extends Reference
	var name: String
	var age: float
	var address: String
	var phone: String

	func _init(field_value_map := {}):
		for key in field_value_map.keys():
			set(key, field_value_map[key])

func _get_data_table():
	# DataType.new({})
	return [
			DataType.new({'name': '张三','age': 15,'address': '陈府井3号','phone': '138456456456',}),
			DataType.new({'name': '李四','age': 15,'address': '第一高级中学教师生活区103号','phone': '138456456456',}),
			DataType.new({'name': '王五','age': 16,'address': '浅水滩1号','phone': '138456456456',}),
			DataType.new({'name': '陈六','age': 17,'address': '六大胡同4号','phone': '138456456456',}),
			DataType.new({'name': '赵七','age': 16,'address': '太阳弯403号','phone': '138456456456',}),
	]

func by(field_name, v) -> DataType:
	return ._by(field_name, v) as DataType

func _get_data_head_def():
	return [
		"name",
		"age",
		"address",
		"phone",
	]

# func by_field1(v) -> DataType:
#   return by("field1", v)
func by_name(v) -> DataType:
	return by("name", v)

func by_age(v) -> DataType:
	return by("age", v)

func by_address(v) -> DataType:
	return by("address", v)

func by_phone(v) -> DataType:
	return by("phone", v)


