extends Node

signal entry_unlocked(entry: JournalEntry)

const ENTRY_DIR := "res://journal/entries/"
const SAVE_PATH := "user://journal.save"

var entries: Dictionary = {}    # id -> JournalEntry
var unlocked: Dictionary = {}   # id -> true
var notes: Dictionary = {}      # id -> String typed by the player

func _ready() -> void:
	for file in ResourceLoader.list_directory(ENTRY_DIR):
		if file.ends_with(".tres"):
			var entry: JournalEntry = load(ENTRY_DIR + file)
			entries[entry.id] = entry
	_load()

func unlock(id: StringName) -> void:
	if unlocked.has(id) or not entries.has(id):
		return
	unlocked[id] = true
	entry_unlocked.emit(entries[id])
	_save()

func is_unlocked(id: StringName) -> bool:
	return unlocked.has(id)

func get_note(id: StringName) -> String:
	return notes.get(id, "")

## Updates the note in memory. Call save() to write it to disk
## (the journal screen does this when it closes).
func set_note(id: StringName, text: String) -> void:
	if text.strip_edges().is_empty():
		notes.erase(id)
	else:
		notes[id] = text

func save() -> void:
	_save()

func _notification(what: int) -> void:
	# Don't lose notes if the game is closed with the journal still open.
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save()

func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	f.store_var({"unlocked": unlocked.keys(), "notes": notes})

func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data = FileAccess.open(SAVE_PATH, FileAccess.READ).get_var()
	if data is Array:
		# Older saves were just the list of unlocked ids.
		data = {"unlocked": data}
	for id in data.get("unlocked", []):
		unlocked[id] = true
	notes = data.get("notes", {})
