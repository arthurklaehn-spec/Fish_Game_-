extends CharacterBody2D

@export var swim_speed: float = 100.0
@export var turn_speed: float = 3.5
@export var min_change_time: float = 1.5
@export var max_change_time: float = 3.5
@export var swim_animation_name: String = "swim"

@export var bob_amplitude: float = 15.0
@export var bob_frequency: float = 3.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

var target_direction: Vector2 = Vector2.RIGHT
var timer: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	# Play the swimming animation if it exists in SpriteFrames
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(swim_animation_name):
		anim_sprite.play(swim_animation_name)
	else:
		anim_sprite.play()

	_pick_new_direction()
	time_passed = randf() * 10.0

func _physics_process(delta: float) -> void:
	time_passed += delta
	timer -= delta
	if timer <= 0.0:
		_pick_new_direction()

	# Smoothly rotate toward the target direction
	var target_angle := target_direction.angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

	# Flip vertically when swimming left so the fish stays upright
	anim_sprite.flip_v = cos(rotation) < 0

	# Combine forward swim velocity with a subtle vertical wave bob
	var forward := Vector2.RIGHT.rotated(rotation) * swim_speed
	var bob := Vector2.UP * cos(time_passed * bob_frequency) * bob_amplitude
	velocity = forward + bob

	move_and_slide()

	# Bounce off walls or tank boundaries
	if get_slide_collision_count() > 0:
		var collision := get_slide_collision(0)
		target_direction = target_direction.bounce(collision.get_normal()).normalized()
		timer = randf_range(min_change_time, max_change_time)

func _pick_new_direction() -> void:
	timer = randf_range(min_change_time, max_change_time)
	target_direction = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-0.35, 0.35)
	).normalized()
