extends Panel

@onready var texture_rect: TextureRect = $PanelContainer/TextureRect
@onready var suggest_price_label: Label = $SuggestPriceLabel
@onready var less_button: Button = $LessButton
@onready var more_button: Button = $MoreButton
@onready var confirm_button: Button = $ConfirmButton
@onready var selling_price_input: LineEdit = $SellingPriceInput

var selling_price: int:
	set(value):
		selling_price = clamp(value,1,999999)
		selling_price_input.text = str(selling_price)



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
	selling_price_input.placeholder_text = "%s" % OriginalPrice
	selling_price = grabbed_slot_data.item_data.sell
	selling_price_input.text = str(selling_price)
	slot = grabbed_slot_data.duplicate() as SlotData
	inventory_data = _inventory_data
	
	call_deferred("adjust_price")
	
	return slot
	


func adjust_price() -> void:
	slot.item_data.sell = selling_price
	inventory_data.inventory_updated.emit(inventory_data)



func _on_less_button_button_down() -> void:
	selling_price = ceil(selling_price / 1.1)
	adjust_price()


func _on_more_button_pressed() -> void:
	selling_price = floor(selling_price * 1.1)
	adjust_price()


func _on_confirm_button_pressed() -> void:
	selling_price_input.text_submitted.emit(selling_price_input.text)
	hide()


func _on_selling_price_input_text_submitted(new_text: String) -> void:
	## this already works
	if new_text.is_valid_int():
		selling_price = int(new_text)
		adjust_price()
		selling_price_input.clear()
	else:
		pass
	




#func _on_selling_price_input_text_changed(new_text: String) -> void:
	##var regex = RegEx.new()
	##regex.compile("[^0-9]")  #delete everything that is not int
	##
	##if regex.search(new_text):
		##print("input")
		##selling_price_input.text = regex.sub(new_text,"",true)
		##selling_price_input.caret_column = selling_price_input.text.length()
		##selling_price = int(new_text)
		##adjust_price()
	#
	##if new_text.is_valid_int():
		##selling_price = int(new_text)
		##adjust_price()
	##else:
		##print('not int')
		#pass
