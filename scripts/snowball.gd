extends RigidBody3D

@onready var debris_particles = $Debris
@onready var smoke_particles = $Smoke
@onready var cleanup_timer: Timer = $CleanupTimer
var hit = false

func _ready() -> void:
	continuous_cd = true
	debris_particles.emitting = false
	smoke_particles.emitting = false
	
	cleanup_timer.one_shot = true

func _emit_particles():
	print(hit)
	if hit == false:
		$MeshInstance3D.hide()
		debris_particles.global_transform = self.global_transform
		smoke_particles.global_transform = self.global_transform

		debris_particles.emitting = true
		smoke_particles.emitting = true

		cleanup_timer.wait_time = 2.0
		cleanup_timer.start()



func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	_emit_particles()
	hit = true


func _on_cleanup_timer_timeout() -> void:
	queue_free()
