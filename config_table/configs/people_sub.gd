
#===============================================#
#                                               #
#      This file is auto-generated by tool      #
#              2021-11-11 03:18:53              #
#                                               #
#===============================================#

extends ConfigTable

class DataType:
	extends Reference
	var job: String

	func _init(field_value_map := {}):
		for key in field_value_map.keys():
			set(key, field_value_map[key])

func _get_data_table():
	# DataType.new({})
	return [
	]

func by(field_name, v) -> DataType:
	return ._by(field_name, v) as DataType

func _get_data_head_def():
	return [
		"job",
	]

# func by_field1(v) -> DataType:
#   return by("field1", v)
func by_job(v) -> DataType:
	return by("job", v)



func all_by_job(v) -> Array:
	return _all_by("job", v)



func has_job(v) -> bool:
	return has("job", v)

