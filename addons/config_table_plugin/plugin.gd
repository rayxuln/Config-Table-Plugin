tool
extends EditorPlugin

const ROOT_DIR_SETTING := 'config_table_plugin/root_directory'
const CONFIG_TABLE_TEMPLATE_PATH_SETTING := 'config_table_plugin/config_table_template_path'
const CONFIG_HELPER_SAVE_PATH_SETTING := 'config_table_plugin/config_helper_save_path'

const CONFIG_TABLES_DIR := 'configs'
const EXCELS_DIR := 'excels'
const DEFS_DIR := 'defs'
const TEMPLATES_DIR := 'templates'

var root_dir := 'res://config_table'
var config_tables_dir:String
var excels_dir:String
var defs_dir:String
var templates_dir:String

var config_table_template_path := path_combine(TEMPLATES_DIR, 'ConfigTable.gd.template')
var config_table_template_actual_path:String
var CONFIG_TABLE_TEMPLATE_ACTUAL_PATH := path_combine(TEMPLATES_DIR, 'ConfigTable.gd.template')
var GDSCRIPT_CONFIG_TABLE_TOOL_PATH := 'tools/gdscript_config_table_tool/GDScriptConfigTableTool.exe'

var config_helper_template_path := path_combine(TEMPLATES_DIR, 'ConfigHelper.gd.template')
var config_helper_template_actual_path:String
var CONFIG_HELPER_TEMPLATE_ACTUAL_PATH := path_combine(TEMPLATES_DIR, 'ConfigHelper.gd.template')
const ConfigHelperGenerator := preload('./tools/config_helper_generator/ConfigHelperGenerator.gd')
var config_helper_generator:ConfigHelperGenerator

var config_helper_save_path := 'ConfigHelper.gd'
const GDSCRIPT_EXT := 'gd'

const TOOL_MENU_NAME := 'Config Table'
var tool_menu:PopupMenu
var EXPORT_ALL_EXCELS_MENU_NAME := tr('Export All Excels')
var EXPORT_ALL_GDSCRIPTS_MENU_NAME := tr('Export All GDScripts')
var EXPORT_CONFIG_HELPER_NAME := tr('Export Config Helper')
var EXPORT_ALL_NAME := tr('Export All')
var CLEAN_ALL_CONFIG_TABLES_NAME := tr('Clean All Config Tables')

const CONFIG_HELPER_AUTOLOAD_NAME := 'ConfigHelper'

enum {
	EXPORT_ALL_EXCELS_MENU_ID = 0,
	EXPORT_ALL_GDSCRIPTS_MENU_ID,
	EXPORT_CONFIG_HELPER_MENU_ID,
	EXPORT_ALL_MENU_ID,
	CLEAN_ALL_CONFIG_TABLES_MENU_ID,
}


func _enter_tree() -> void:
	load_project_settings()
	check_and_create_directories()
	check_and_copy_config_table_template()
	check_gdscript_config_table_tool()
	check_and_copy_config_helper_template()
	create_config_helper_genreator()
	
	get_editor_interface().get_resource_filesystem().scan()
	
	create_tool_menu()
	
	check_and_update_config_helper_singleton()

func _exit_tree() -> void:
	destory_tool_menu()
	
	if ProjectSettings.has_setting('autoload/%s' % CONFIG_HELPER_AUTOLOAD_NAME):
		remove_autoload_singleton(CONFIG_HELPER_AUTOLOAD_NAME)

#---- Methods -----
func check_and_update_config_helper_singleton():
	if ProjectSettings.has_setting('autoload/%s' % CONFIG_HELPER_AUTOLOAD_NAME):
		remove_autoload_singleton(CONFIG_HELPER_AUTOLOAD_NAME)
	var path = ProjectSettings.localize_path(root_dir)
	path = path_combine(path, config_helper_save_path)
	var dir = Directory.new()
	if dir.file_exists(path):
		call_deferred('add_autoload_singleton', CONFIG_HELPER_AUTOLOAD_NAME, path)

func create_tool_menu():
	tool_menu = PopupMenu.new()
	add_tool_submenu_item(TOOL_MENU_NAME, tool_menu)
	
	tool_menu.connect('id_pressed', self, '_on_tool_menu_pressed')
	
	tool_menu.add_item(EXPORT_ALL_EXCELS_MENU_NAME, EXPORT_ALL_EXCELS_MENU_ID)
	tool_menu.add_item(EXPORT_ALL_GDSCRIPTS_MENU_NAME, EXPORT_ALL_GDSCRIPTS_MENU_ID)
	tool_menu.add_item(EXPORT_CONFIG_HELPER_NAME, EXPORT_CONFIG_HELPER_MENU_ID)
	tool_menu.add_item(CLEAN_ALL_CONFIG_TABLES_NAME, CLEAN_ALL_CONFIG_TABLES_MENU_ID)
	tool_menu.add_separator()
	tool_menu.add_item(EXPORT_ALL_NAME, EXPORT_ALL_MENU_ID)
	

func destory_tool_menu():
	if tool_menu:
		remove_tool_menu_item(TOOL_MENU_NAME)

func get_current_workdirectory():
	var s := get_script() as GDScript;
	return ProjectSettings.globalize_path(s.get_path().get_base_dir())

func load_project_settings():
	if ProjectSettings.has_setting(ROOT_DIR_SETTING):
		root_dir = ProjectSettings.get_setting(ROOT_DIR_SETTING)
	else:
		ProjectSettings.set_setting(ROOT_DIR_SETTING, root_dir)
	
	if ProjectSettings.has_setting(CONFIG_TABLE_TEMPLATE_PATH_SETTING):
		config_table_template_path = ProjectSettings.get_setting(CONFIG_TABLE_TEMPLATE_PATH_SETTING)
	else:
		ProjectSettings.set_setting(CONFIG_TABLE_TEMPLATE_PATH_SETTING, config_table_template_path)
	
	if ProjectSettings.has_setting(CONFIG_HELPER_SAVE_PATH_SETTING):
		config_helper_save_path = ProjectSettings.get_setting(CONFIG_HELPER_SAVE_PATH_SETTING)
	else:
		ProjectSettings.set_setting(CONFIG_HELPER_SAVE_PATH_SETTING, config_helper_save_path)

func path_combine(base_dir, dir_name) -> String:
	return '%s/%s' % [base_dir, dir_name]

func check_and_create_directories():
	var dir = Directory.new()
	root_dir = ProjectSettings.globalize_path(root_dir)
	if not dir.dir_exists(root_dir):
		var err = dir.make_dir_recursive(root_dir)
		if err != OK:
			printerr('Can\'t make dir for root: %s' % root_dir)
			return
	
	config_tables_dir = path_combine(root_dir, CONFIG_TABLES_DIR)
	excels_dir = path_combine(root_dir, EXCELS_DIR)
	defs_dir = path_combine(root_dir, DEFS_DIR)
	templates_dir = path_combine(root_dir, TEMPLATES_DIR)
	
	if not dir.dir_exists(config_tables_dir):
		var err = dir.make_dir_recursive(config_tables_dir)
		if err != OK:
			printerr('Can\'t make dir for: %s' % config_tables_dir)
			return
	if not dir.dir_exists(excels_dir):
		var err = dir.make_dir_recursive(excels_dir)
		if err != OK:
			printerr('Can\'t make dir for: %s' % excels_dir)
			return
	if not dir.dir_exists(defs_dir):
		var err = dir.make_dir_recursive(defs_dir)
		if err != OK:
			printerr('Can\'t make dir for: %s' % defs_dir)
			return
	if not dir.dir_exists(templates_dir):
		var err = dir.make_dir_recursive(templates_dir)
		if err != OK:
			printerr('Can\'t make dir for: %s' % templates_dir)
			return
	

func check_and_copy_config_table_template():
	var dir = Directory.new()
	config_table_template_actual_path = path_combine(root_dir, config_table_template_path)
	var source = path_combine(get_current_workdirectory(), CONFIG_TABLE_TEMPLATE_ACTUAL_PATH)
	var do_copy = not dir.file_exists(config_table_template_actual_path)
	if do_copy:
		var err = dir.copy(source, config_table_template_actual_path)
		if err != OK:
			printerr('Can\'t copy template file from %s to: %s' % [source, config_table_template_actual_path])
			return

func check_and_copy_config_helper_template():
	var dir = Directory.new()
	config_helper_template_actual_path = path_combine(root_dir, config_helper_template_path)
	var source = path_combine(get_current_workdirectory(), CONFIG_HELPER_TEMPLATE_ACTUAL_PATH)
	var do_copy = not dir.file_exists(config_helper_template_actual_path)
	if do_copy:
		var err = dir.copy(source, config_helper_template_actual_path)
		if err != OK:
			printerr('Can\'t copy template file from %s to: %s' % [source, config_helper_template_actual_path])
			return

func execute_gdscript_config_table_tool(args:=[], show_output:=false):
	var e = path_combine(get_current_workdirectory(), GDSCRIPT_CONFIG_TABLE_TOOL_PATH)
	e = ProjectSettings.globalize_path(e)
	var output := []
	var code = OS.execute(e, args, true, output, true)
	if code != 0:
		printerr('Execute the gdscript config table tool failed: %s' % e)
		printerr('Code: %s' % code)
		printerr('Output: %s' % [output])
	else:
		if show_output and not output.empty():
			if output.size() != 1 or output[0] != '':
				print(output)
	get_editor_interface().get_resource_filesystem().scan()

func check_gdscript_config_table_tool():
	execute_gdscript_config_table_tool(['-h'])

func create_config_helper_genreator():
	config_helper_generator = ConfigHelperGenerator.new(config_helper_template_actual_path)

func get_config_table_path_list():
	var dir = Directory.new()
	var err = dir.open(config_tables_dir)
	if err != OK:
		printerr('Can\'t access config tables dir: %s, code: %s' % [config_tables_dir, err])
		return []
	err = dir.list_dir_begin(true, true)
	if err != OK:
		printerr('Can\'t list dir begin at: %s, code: %s' % [config_tables_dir, err])
		return []
	var res := []
	var file_name = dir.get_next()
	while file_name != '':
		if not dir.current_is_dir():
			if file_name.ends_with('.%s' % GDSCRIPT_EXT):
				res.append(path_combine(CONFIG_TABLES_DIR, file_name))
		file_name = dir.get_next()
	dir.list_dir_end()
	return res

func get_config_helper_save_path():
	var path = config_helper_save_path
	if path.is_abs_path():
		path = ProjectSettings.globalize_path(path)
	if path.is_rel_path():
		path = path_combine(root_dir, path)
	return path

func export_all_excels(scan:=true):
	execute_gdscript_config_table_tool(['export_all_excel', '-od', (excels_dir), '-dd', (defs_dir)], true)
	print('Export all excels done!')
	if scan:
		get_editor_interface().get_resource_filesystem().scan()

func export_all_gdscripts(scan:=true):
	execute_gdscript_config_table_tool(['export_all_gdscript', '-od', (config_tables_dir), '-ed', (excels_dir), '-dd', (defs_dir), '-tp', (config_table_template_actual_path)], true)
	print('Export all gdscripts done!')
	if scan:
		get_editor_interface().get_resource_filesystem().scan()

func export_config_helper(scan:=true):
	config_helper_generator.create(get_config_table_path_list())
	config_helper_generator.save_to(get_config_helper_save_path())
	print('Export config helper done!')
	if scan:
		get_editor_interface().get_resource_filesystem().scan()
	check_and_update_config_helper_singleton()

func export_all(scan:=true):
	export_all_excels(false)
	clean_all_config_tables(false, false)
	export_all_gdscripts(false)
	export_config_helper(false)
	print('Export all done!')
	if scan:
		get_editor_interface().get_resource_filesystem().scan()

func clean_all_config_tables(scan:=true, with_config_helper:=true):
	var dir = Directory.new()
	var err = dir.open(config_tables_dir)
	if err != OK:
		printerr('Can\'t open config tables directory: %s, code: %s' % [config_tables_dir, err])
		return
	err = dir.list_dir_begin(true, true)
	if err != OK:
		printerr('Can\'t list dir begin of: %s, code: %s' % [config_tables_dir, err])
		return
	
	var file_name = dir.get_next()
	var file_list := []
	while file_name != "":
		if not dir.current_is_dir():
			if file_name.ends_with('.%s' % GDSCRIPT_EXT):
				file_list.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	for f in file_list:
		err = dir.remove(f)
		if err != OK:
			printerr('Can\'t remove file: %s, code: %s' % [f, err])
			continue
	
	if with_config_helper:
		export_config_helper(false)
	print('Clean all config tables done!')
	if scan:
		get_editor_interface().get_resource_filesystem().scan()
#----- Signals -----
func _on_tool_menu_pressed(id):
	match id:
		EXPORT_ALL_EXCELS_MENU_ID:
			export_all_excels()
		EXPORT_ALL_GDSCRIPTS_MENU_ID:
			export_all_gdscripts()
		EXPORT_CONFIG_HELPER_MENU_ID:
			export_config_helper()
		EXPORT_ALL_MENU_ID:
			export_all()
		CLEAN_ALL_CONFIG_TABLES_MENU_ID:
			clean_all_config_tables()
