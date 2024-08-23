extends CanvasLayer
class_name Program

# Variables
@export var selectFileDialog : FileDialog
@export var selectFileInput : LineEdit
@export var selectFileButton : Button
@export var exportFilePathInput : LineEdit
@export var exportFilePathButton : Button
@export var exportFileName : LineEdit
@export var columnInput : LineEdit
@export var addColumnButton : Button
@export var columnContainer : VBoxContainer
@export var columnUIPrefab : PackedScene
@export var convertButton : Button
@export var saveFileDialog : FileDialog


var columns : Array[String] = []
var filePaths : PackedStringArray
var csvFileInput : String = ""
var saveFilePath : String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	selectFileDialog.files_selected.connect(_select_files)
	selectFileButton.pressed.connect(_open_select_file)
	addColumnButton.pressed.connect(_add_column)
	convertButton.pressed.connect(_convert_pressed)
	saveFileDialog.file_selected.connect(_save_export_path)
	exportFilePathButton.pressed.connect(_select_export_file_path)


#region Open Files
func _open_select_file() -> void:
	selectFileDialog.popup()


func _select_files(_filePaths : PackedStringArray) -> void:
	filePaths = _filePaths
	
	if filePaths.size() == 1:
		selectFileInput.text = filePaths[0]
	else:
		selectFileInput.text = "Multiple Files Selected"
#endregion


#region Adjust Columns
func _add_column() -> void:
	var newColumn : ColumnData = columnUIPrefab.instantiate()
	columnContainer.add_child(newColumn)
	newColumn.initialize(columnInput.text)
	columns.append(columnInput.text)
	columnInput.text = ""
	newColumn.remove_column.connect(_remove_column)


func _remove_column(_column : String) -> void:
	columns.erase(_column)
#endregion


func _convert_to_csv() -> String:
	var csvData : String = ""
	
	## Convert each file into a CSV file
	for filePath in filePaths:
		var markdownFile = FileAccess.open(filePath, FileAccess.READ)
		
		csvData += "\n"
		
		var line : String = markdownFile.get_line()
		
		while line != "":
			var readWord : String = ""
			
			## Store each character of the line
			for character in line:
				if character == ":": ## Reach end of "section"
					for column in columns: ## Check if it matches one of the columns
						if readWord == column: ## If it does, store remainder of string
							csvData += line.substr(readWord.length() + 2) + "|"
							continue
				else:
					readWord += character
			
			line = markdownFile.get_line()
		
		## Remove final delimitters
		csvData = csvData.left(csvData.length() - 1)
		
		markdownFile.close()
	
	print("CSV FILE: ", csvData)
	return csvData


#region Export Files
func _convert_pressed() -> void:
	_export_to_csv()


func _export_to_csv() -> void:
	var csvFile = FileAccess.open(saveFilePath, FileAccess.WRITE)
	csvFile.store_string(_convert_to_csv())
	csvFile.close()


func _save_export_path(_savePath : String) -> void:
	saveFilePath = _savePath
	exportFilePathInput.text = saveFilePath


func _select_export_file_path() -> void:
	saveFileDialog.popup()
#endregion
