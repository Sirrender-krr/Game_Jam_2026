extends PanelContainer

signal slot_clicked(index: int, button: int)

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel
@onready var price_label: Label = $PriceLabel
@onready var sell_label: Label = $SellLabel  #only used in shop


func set_slot_data(slot_data: SlotData, is_shop = null) -> void:
	var item_data = slot_data.item_data
	if is_shop:
		texture_rect.texture = item_data.texture
		tooltip_text = "%s\n%s\nBuy: %s\nSell: %s" %[item_data.name,item_data.description,item_data.buy,item_data.sell]
		if slot_data.quantity > 1:
			#quantity_label.text = "x%s" % slot_data.quantity
			quantity_label.text = "x%s" %format_with_commas(slot_data.quantity)
			quantity_label.show()
		else:
			quantity_label.hide()
		
		if item_data is ItemDataCoin:
			sell_label.text = ""
		else:
			sell_label.text = format_with_commas(item_data.buy)
	else:
		texture_rect.texture = item_data.texture
		tooltip_text = "%s\n%s\nBuy: %s\nSell: %s" %[item_data.name,item_data.description,item_data.buy,item_data.sell]
		if slot_data.quantity > 1:
			#quantity_label.text = "x%s" % slot_data.quantity
			quantity_label.text = "x%s" %format_with_commas(slot_data.quantity)
			quantity_label.show()
		else:
			quantity_label.hide()
		
		if item_data is ItemDataCoin:
			price_label.text = ""
		else:
			price_label.text = format_with_commas(item_data.sell)



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton\
	and (event.button_index == MOUSE_BUTTON_LEFT\
	or event.button_index == MOUSE_BUTTON_RIGHT)\
	and event.is_pressed():
		slot_clicked.emit(get_index(),event.button_index)


## Format with commas separated number
func format_with_commas(value:int) -> String:
	var s = str(value)
	var result = ""
	var count = 0
	for i in range(s.length()-1,-1,-1):
		result = s[i] + result
		count += 1
		if count == 3 and i >0:
			result = ","+result
			count = 0
	return result
