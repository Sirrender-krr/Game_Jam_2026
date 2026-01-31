extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var MAX_STACK_SIZE: int = 1
@export var buy: int
@export var sell: int
@export var texture: AtlasTexture
