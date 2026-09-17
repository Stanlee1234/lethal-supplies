@tool
extends RigidBody2D
class_name ThrowableProp

@export var item_data: ItemData:
	set(value):
		item_data = value
		if is_node_ready():
			_apply_item_data()

@export var spin_amount: float = 12.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_held: bool = false

func _ready() -> void:
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	linear_damp = 3.5
	angular_damp = 2.5
	_apply_item_data()

func _apply_item_data() -> void:
	if not item_data:
		return

	if sprite:
		sprite.texture = item_data.texture
		sprite.position = item_data.sprite_offset

	if collision_shape:
		var box := RectangleShape2D.new()
		box.size = item_data.collision_size
		collision_shape.shape = box
		collision_shape.position = item_data.collision_offset

func pick_up(holder: Node2D) -> void:
	is_held = true
	freeze = true
	collision_shape.set_deferred("disabled", true)
	
	reparent(holder)
	position = Vector2.ZERO
	rotation = 0.0

func drop() -> void:
	is_held = false
	var world = get_tree().current_scene
	reparent(world)
	
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
	freeze = false
	collision_shape.set_deferred("disabled", false)

func launch(direction: Vector2, force: float) -> void:
	drop()
	var weight: float = item_data.weight_tier if item_data else 1.0
	var speed_val: float = force / max(weight, 0.1)
	linear_velocity = direction * speed_val
	
	var spin_dir: float = [-1.0, 1.0].pick_random()
	angular_velocity = spin_dir * spin_amount
