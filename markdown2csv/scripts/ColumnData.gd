extends HBoxContainer
class_name ColumnData

# Variables
@export var columnData : LineEdit
@export var removeColButton : Button


# Signals
signal remove_column(_colName : String)


# Called when the node enters the scene tree for the first time.
func _ready():
	removeColButton.pressed.connect(_remove_column)


func initialize(_columnName : String) -> void:
	columnData.text = _columnName


func _remove_column() -> void:
	remove_column.emit(columnData.text)
	queue_free()
