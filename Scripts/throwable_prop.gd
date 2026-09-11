extends RigidBody2D
class_name ThrowableProp

@export var item_name: String = "Telephone"
@export var weight_tier: float = 0.5
@export var durability: int = 3
@export var damage: int = 20

var is_held: bool = false

func pick_up() -> void:
	is_held = true
	freeze = true
	collision_layer = 0
	collision_mask = 0

func drop() -> void:
	is_held = false
	freeze = false
	collision_layer = 1
	collision_mask = 1

func launch(direction: Vector2, force: float) -> void:
	drop()
	var final_impulse = direction * (force / max(weight_tier, 0.1))
	apply_central_impulse(final_impulse)
