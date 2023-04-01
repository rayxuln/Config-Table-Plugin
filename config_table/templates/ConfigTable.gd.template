extends ConfigTable

class DataType:
    extends RefCounted
{FIELD_DEC_LIST}
    func _init(field_value_map := {}):
        for key in field_value_map.keys():
            set(key, field_value_map[key])

func _get_data_table():
    # DataType.new({})
    return [
{DATA_LIST}        ]

func by(field_name, v) -> DataType:
    return super._by(field_name, v) as DataType

func _get_data_head_def():
    return [
{DATA_HEAD_DEF}    ]

# func by_field1(v) -> DataType:
#   return by("field1", v)
{BY_FIELD_FUNC_LIST}