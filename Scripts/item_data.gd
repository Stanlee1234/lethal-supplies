extends Resource
class_name ItemData

@export var item_name: String = "Item"
@export var texture: Texture2D
@export var weight_tier: float = 1.0
@export var durability: int = 3
@export var damage: int = 20
@export var collision_size: Vector2 = Vector2(16, 16)

@export var sprite_offset: Vector2 = Vector2.ZERO
@export var collision_offset: Vector2 = Vector2.ZERO
