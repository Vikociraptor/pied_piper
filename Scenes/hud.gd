extends CanvasLayer
## Hotbar showing the player's items and the key that equips each one.

const DIMMED := 0.4

@export var player: Node

@onready var radio_slot: Control = %RadioSlot
@onready var glass_slot: Control = %GlassSlot

func _ready() -> void:
	if player == null:
		push_warning("HUD: no player assigned, so the equipped item won't be highlighted.")
		return
	player.equipped_changed.connect(_on_equipped_changed)
	_on_equipped_changed(player.equipped)

func _on_equipped_changed(item: int) -> void:
	radio_slot.modulate.a = 1.0 if item == player.Item.RADIO else DIMMED
	glass_slot.modulate.a = 1.0 if item == player.Item.GLASS else DIMMED
