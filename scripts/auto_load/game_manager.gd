extends Node

var day: int:
	set(d):
		day = d
		print(day)
var coin_gain: int
var coin_loss: int
var player_inventory : InventoryData = preload("res://inventory/resources/player_inventory.tres")
var table_inventory: InventoryDataTable = preload("res://inventory/resources/table_inventory.tres")

func _ready() -> void:
	day = 0
	coin_gain = 0
	coin_loss = 0

func clear_balance() -> void:
	coin_gain = 0
	coin_loss = 0
