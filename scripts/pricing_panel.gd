extends Panel

@onready var texture_rect: TextureRect = $PanelContainer/TextureRect
@onready var suggest_price_label: Label = $SuggestPriceLabel
@onready var selling_price_label: Label = $SellingPriceLabel
@onready var less_button: Button = $LessButton
@onready var more_button: Button = $MoreButton
@onready var confirm_button: Button = $ConfirmButton

var selling_price: int:
	set(value):
		selling_price = clamp(value,1,999999)
		selling_price_label.text = "%s" %selling_price


var inventory_data: InventoryData
var slot: SlotData

func _ready() -> void:
	hide()

func open_price_panel(grabbed_slot_data: SlotData, Index: int, _inventory_data: InventoryData) -> SlotData:
	var texture = grabbed_slot_data.item_data.texture
	texture_rect.texture = texture
	
	var OriginalPrice = grabbed_slot_data.item_data.suggest_selling
	var ActualSelling = grabbed_slot_data.item_data.sell
	suggest_price_label.text = "%s" % OriginalPrice
	selling_price = grabbed_slot_data.item_data.sell
	selling_price_label.text = "%s" % ActualSelling
	slot = grabbed_slot_data.duplicate() as SlotData
	inventory_data = _inventory_data
	
	call_deferred("adjust_price")
	
	return slot
	


func adjust_price() -> void:
	
	slot.item_data.sell = selling_price
	
	inventory_data.inventory_updated.emit(inventory_data)



func _on_less_button_button_down() -> void:
	selling_price -= 100
	adjust_price()


func _on_more_button_pressed() -> void:
	selling_price += 100
	adjust_price()


func _on_confirm_button_pressed() -> void:
	hide()
