extends RefCounted
class_name ConfigTable

class Iterator:
	extends RefCounted
	
	var current_index:int
	
	var that:WeakRef
	func _init(t) -> void:
		that = t
	
	func _iter_init(arg):
		current_index = 0
		return current_index < that.get_ref().data_list.size()
	
	func _iter_next(arg):
		current_index += 1
		return current_index < that.get_ref().data_list.size()
	
	func _iter_get(arg):
		return that.get_ref().data_list[current_index]

var data_list:Array

func _init() -> void:
	data_list = _get_data_table()

func _get_data_table():
	return []

func _by(field_name, v):
	for data in data_list:
		if data[field_name] == v:
			return data
	var p:String = get_script().get_path()
	p = p.get_file().get_basename()
	printerr('No field "%s" has value: "%s" in table: %s' % [field_name, v, p])
	return null

func _all_by(field_name, v):
	var res := []
	for data in data_list:
		if data[field_name] == v:
			res.append(data)
	return res

func has(field_name, v) -> bool:
	for data in data_list:
		if data[field_name] == v:
			return true
	return false

func get_iterator() -> Iterator:
	return Iterator.new(weakref(self))
