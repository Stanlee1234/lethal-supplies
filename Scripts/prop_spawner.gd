extends Node2D
class_name PropSpawner

@export var prop_scene: PackedScene = preload("res://Scenes/throwable_prop.tscn")

@export var item_data_options: Array[ItemData] = [
	preload("res://Props/flag_grey.tres"),
	preload("res://Props/flag_blue.tres"),
	preload("res://Props/flag_red.tres"),
	preload("res://Props/flag_yellow.tres")
]

@export_range(1, 100) var minimum_props: int = 5
@export_range(1, 100) var maximum_props: int = 15
@export var spawn_area: Rect2 = Rect2(-620, -360, 1180, 680)
@export var player: Node2D
@export var minimum_distance_from_player: float = 100.0
@export var maximum_spawn_attempts: int = 30

var random_generator := RandomNumberGenerator.new()


func _ready() -> void:
	random_generator.randomize()
	spawn_props()


func spawn_props() -> void:
	if item_data_options.is_empty():
		push_warning("No item data has been added to PropSpawner.")
		return

	var prop_count := random_generator.randi_range(
		minimum_props,
		maximum_props
	)

	for i in range(prop_count):
		var spawn_position: Variant = get_valid_spawn_position()

		if spawn_position == null:
			push_warning("Could not find a valid position for prop %d." % i)
			continue

		var prop := prop_scene.instantiate() as ThrowableProp

		var random_item_index: int = random_generator.randi_range(
			0,
			item_data_options.size() - 1
		)

		prop.item_data = item_data_options[random_item_index]
		prop.global_position = spawn_position as Vector2
		prop.rotation = random_generator.randf_range(0.0, TAU)

		add_child(prop)

func get_valid_spawn_position() -> Variant:
	for attempt in range(maximum_spawn_attempts):
		var position := Vector2(
			random_generator.randf_range(
				spawn_area.position.x,
				spawn_area.end.x
			),
			random_generator.randf_range(
				spawn_area.position.y,
				spawn_area.end.y
			)
		)

		if player and position.distance_to(player.global_position) < minimum_distance_from_player:
			continue

		return position

	return null
