extends CanvasLayer
class_name Program

# Variables
@export var selectFileDialog : FileDialog
@export var selectFileInput : LineEdit
@export var selectFileButton : Button
@export var columnInput : LineEdit
@export var addColumnButton : Button
@export var columnContainer : VBoxContainer
@export var columnUIPrefab : PackedScene
@export var convertButton : Button
@export var saveFileDialog : FileDialog


var columns : Array[String] = []
var filePaths : PackedStringArray
var csvFileInput : String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	selectFileDialog.files_selected.connect(_select_files)
	selectFileButton.pressed.connect(_open_select_file)
	addColumnButton.pressed.connect(_add_column)
	convertButton.pressed.connect(_convert_pressed)
	saveFileDialog.file_selected.connect(_export_csv_file)


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
	#
	### Store the columns
	#for column in columns:
		#csvData += column + "|"
	#
	### Remove the last delimitter (not needed)
	#csvData = csvData.left(csvData.length() - 1)
	
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
	
	return csvData


#region Export Files
func _convert_pressed() -> void:
	saveFileDialog.popup()


func _export_csv_file(_savePath : String) -> void:
	var csvFile = FileAccess.open(_savePath, FileAccess.WRITE)
	csvFile.store_string(_convert_to_csv())
#endregion
