extends CanvasLayer
## The journal screen. Reads entries and progress from the Journal autoload.
## Opening it pauses the game; this node keeps running (process_mode = Always).

const LOCKED_TITLE := "???"
const LOCKED_TEXT := "Inspect this with the magnifying glass to learn about it."
const SILHOUETTE := Color(0, 0, 0, 0.7)

@onready var window: Control = %Window
@onready var tabs: Container = %Tabs
@onready var grid: GridContainer = %GridContainer
@onready var empty_label: Label = %EmptyLabel
@onready var detail_icon: TextureRect = %DetailIcon
@onready var detail_title: Label = %DetailTitle
@onready var detail_text: Label = %DetailText
@onready var notes_heading: Label = %NotesHeading
@onready var notes: TextEdit = %Notes
@onready var toast: Label = %Toast

var category := "Animals"
var _toast_tween: Tween
# The entry whose notes are in the notes box (empty when none is shown).
var _notes_id: StringName = &""

func _ready() -> void:
	var group := ButtonGroup.new()
	for tab: Button in tabs.get_children():
		tab.button_group = group
		tab.pressed.connect(_show_category.bind(tab.text))
	(tabs.get_child(0) as Button).button_pressed = true

	Journal.entry_unlocked.connect(_on_entry_unlocked)
	notes.text_changed.connect(_on_notes_changed)
	_show_category(category)

# _input rather than _unhandled_input: while the journal is open its buttons
# have focus, and the GUI would otherwise eat Tab for focus navigation.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_journal"):
		_set_open(not window.visible)
		get_viewport().set_input_as_handled()
	elif window.visible and event.is_action_pressed("ui_cancel"):
		# First Esc stops typing in the notes box; the next one closes.
		if notes.has_focus():
			notes.release_focus()
		else:
			_set_open(false)
		get_viewport().set_input_as_handled()

func _set_open(open: bool) -> void:
	window.visible = open
	get_tree().paused = open
	if open:
		_show_category(category)
	else:
		notes.release_focus()
		Journal.save()

func _show_category(new_category: String) -> void:
	category = new_category
	for child in grid.get_children():
		child.queue_free()
	_clear_detail()

	var ids := Journal.entries.keys().filter(
		func(id): return Journal.entries[id].category == category)
	ids.sort()
	empty_label.visible = ids.is_empty()
	for id in ids:
		grid.add_child(_make_card(Journal.entries[id]))

func _make_card(entry: JournalEntry) -> Button:
	var unlocked := Journal.is_unlocked(entry.id)
	var card := Button.new()
	card.custom_minimum_size = Vector2(80, 80)
	card.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	card.icon = entry.icon
	card.expand_icon = true
	card.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	card.text = entry.title if unlocked else LOCKED_TITLE
	if not unlocked:
		for state in ["normal", "hover", "pressed", "focus", "hover_pressed"]:
			card.add_theme_color_override("icon_%s_color" % state, SILHOUETTE)
	card.set_meta("entry_id", entry.id)
	card.pressed.connect(_show_detail.bind(entry))
	return card

## Opens the journal on the given entry: its tab, its card focused, its page shown.
func open_to(entry: JournalEntry) -> void:
	_set_open(true)
	for tab: Button in tabs.get_children():
		if tab.text == entry.category:
			tab.button_pressed = true  # doesn't emit `pressed`, so switch manually
			break
	_show_category(entry.category)
	_show_detail(entry)
	for card in grid.get_children():
		# Old cards stay in the grid until the end of the frame; skip them.
		if not card.is_queued_for_deletion() and card.get_meta("entry_id") == entry.id:
			card.grab_focus()
			break

func _show_detail(entry: JournalEntry) -> void:
	var unlocked := Journal.is_unlocked(entry.id)
	detail_icon.texture = entry.icon
	detail_icon.modulate = Color.WHITE if unlocked else SILHOUETTE
	detail_title.text = entry.title if unlocked else LOCKED_TITLE
	detail_text.text = entry.description if unlocked else LOCKED_TEXT

	# Notes only for entries the player has actually found.
	_notes_id = entry.id if unlocked else &""
	notes.text = Journal.get_note(entry.id) if unlocked else ""
	notes_heading.visible = unlocked
	notes.visible = unlocked

func _clear_detail() -> void:
	detail_icon.texture = null
	detail_title.text = ""
	detail_text.text = "Select an entry."
	_notes_id = &""
	notes_heading.hide()
	notes.hide()

func _on_notes_changed() -> void:
	if _notes_id != &"":
		Journal.set_note(_notes_id, notes.text)

func _on_entry_unlocked(entry: JournalEntry) -> void:
	open_to(entry)

	toast.text = "New journal entry: %s" % entry.title
	toast.modulate.a = 1.0
	toast.show()
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(2.0)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.5)
	_toast_tween.tween_callback(toast.hide)
