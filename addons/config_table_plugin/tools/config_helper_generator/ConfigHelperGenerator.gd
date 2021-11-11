extends Reference

var template_path:String

var template_code:String
var source_code:String


func _init(t:String) -> void:
	template_path = t
#----- Methods -----
func clear_code():
	source_code = ''

func create(config_table_path_list:Array):
	var gen_map := {}
	gen_map['CONFIG_TABLE_LIST'] = gen_table_list(config_table_path_list)

	clear_code()
	gen_code(gen_map)

func gen_table_list(config_table_path_list:Array):
	var INDENT := 0
	var TEMPLATE := '{0}var {1} := preload("{2}").new()'
	var indent = gen_indent(INDENT)
	var res := ''
	for p in config_table_path_list:
		var path:String = p
		var table_name = path.get_file().trim_suffix('.%s' % path.get_extension())
		res += TEMPLATE.format([indent, table_name, path]) + '\n'
	return res

func gen_code(gen_map:Dictionary):
	read_template()
	source_code = template_code
	for k in gen_map:
		source_code = source_code.replace('{%s}' % k, gen_map[k])

func gen_indent(n:int):
	var res = ''
	for i in n:
		res += '\t'
	return res

func read_template():
	var file = File.new()
	var err = file.open(template_path, File.READ)
	if err != OK:
		printerr('Can\'t open tempalte file: %s, code: %s' % [template_path, err])
		return
	template_code = file.get_as_text()
	file.close()

func save_to(path):
	var err
	var dir = Directory.new()
	if dir.file_exists(path):
		err = dir.remove(path)
		if err != OK:
			printerr('Can\'t remove the old file: %s, code: %s' % [path, err])
			return
	var file = File.new()
	err = file.open(path, File.WRITE)
	if err != OK:
		printerr('Can\'t open file: %s, code: %s' % [path, err])
		return
	file.store_string(source_code)
	file.flush()
	file.close()
#----- Signals -----


