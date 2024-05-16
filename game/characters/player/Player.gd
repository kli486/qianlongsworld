extends CharacterBody3D

@export var warp_location = Vector3(0,2,0)
@export var min_y : int = -20

@onready var neck = $Neck
@onready var main_cam = $Neck/Camera3D as Camera3D
@onready var secondary_cam = $Neck/Camera3D2 as Camera3D
var is_main_camera_active = true
var active_cam = main_cam


var speed = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Specify if being observed
var observed = null
var talking = false

func switch_camera():
	is_main_camera_active = !is_main_camera_active
	main_cam.current = is_main_camera_active
	secondary_cam.current = !is_main_camera_active
	active_cam = main_cam if is_main_camera_active else secondary_cam


# set up mouse handling
func _unhandled_input(event):
	if active_cam == null:
		active_cam = main_cam
	if event.is_action_pressed("switch_camera"):
		switch_camera()
	if event is InputEventMouseButton and not talking:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.01)
			active_cam.rotate_x(-event.relative.y * 0.01)
			active_cam.rotation.x = clamp(active_cam.rotation.x, deg_to_rad(-60), deg_to_rad(90))
	if event.is_action_pressed("speed_up"):
		speed += 1
	if event.is_action_pressed("speed_down"):
		speed -= 1
		if speed < 0:
			speed = 0
			
	if event.is_action_pressed("show_new_painting"):	
		var gallery_building = get_tree().current_scene.get_node("gallery_building")
		if gallery_building.get_is_entered():
			var painting = get_tree().current_scene.get_node("painting")
			painting.show_new_painting()
	
	if event.is_action_pressed("view_painting_mode"):
		var gallery_building = get_tree().current_scene.get_node("gallery_building")
		if gallery_building.get_is_entered():
			var painting = get_tree().current_scene.get_node("painting")
			painting.switch_mode()
		else:
			SceneSwitcher.switch_scene("res://levels/rzheng/qingming_viewer.tscn")
			
	#if event.is_action_pressed("interact"):
		## check for what we are interacting with
		#
		#print(SqlController.get_item_data(1))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if global_position.y < min_y:
		global_position = warp_location

	move_and_slide()

func _process(_delta):
	var coll = %RayCast3D.get_collider()
	var coll2 = %RayCast3D2.get_collider()
	if is_main_camera_active:
		if coll != observed:
			if coll != null:
				print(coll.get_parent().item.name)
			if observed != null :	
				pass
			observed = coll
	else:
		observed = null
		if coll2 != observed:
			if coll2 != null:
				print(coll2.get_parent().item.name)
			if observed != null :	
				pass
			observed = coll2
	
func player():
	pass
