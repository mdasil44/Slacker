extends Node2D

signal state_changed(new_state)

# potential states for state machine
enum State {
	PATROL,
	ENGAGE,
	FOLLOW
}

onready var PlayerDetectionZone = $PlayerDetectionZone

var detection_radius_default = 400
var detection_sneak_modifier = 0.25
var detection_radius = detection_radius_default
var detection_angle = 180
var active_chase = false # is the actor going to chase the player once they are seen
var patrol = true
var chase_timeout = 2.0 # how long until actor stops chasing once they lost line-of-sight

var current_state: int = State.PATROL setget set_state # whenver state changes, call set_state function
var player: Node = null
var action = null

var detection_color_default = Color(0.867, 0.91, 0.247, 0.1)
var detection_color_sneak = Color(0.867, 0.91, 0.247, 0.3)
var detection_color = detection_color_default
var laser_color = Color(1.0, 0.329, 0.298, 1.0)

var target
var hit_pos
var ray_visual = true

export (float) var patrol_time = 5.0
var patrol_timer = Timer.new()
var origin: = Vector2.ZERO # origin about which the actor will "patrol"
var reset_rotation = false
var direction = 1

func _ready() -> void:
	patrol_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	patrol_timer.set_wait_time(patrol_time)
	patrol_timer.set_one_shot(true)
	add_child(patrol_timer)
	patrol_timer.connect("timeout", self, "timeout")
	
	$PlayerDetectionZone/CollisionShape2D.shape.radius = detection_radius


func set_action(action):
	self.action = action


func set_state(new_state: int):
	if new_state == current_state:
		return
	
	if new_state == State.PATROL:
		patrol_timer.start()
	
	current_state = new_state
	emit_signal("state_changed", current_state)


func _physics_process(delta: float) -> void:
	update()
	
	if Input.is_action_pressed("sneak"):
		detection_radius = detection_radius_default * detection_sneak_modifier
		detection_color = detection_color_sneak
	else:
		detection_radius = detection_radius_default
		detection_color = detection_color_default
	
	var destination: = Vector2.ZERO
	match current_state:
		State.PATROL: # have not seen a player in a while, random movements about origin
			if reset_rotation:
				var actor_rotation = abs(get_parent().rotation)
				# if actor isn't rotated in a cardinal direction, make them face one
				if actor_rotation <= PI and actor_rotation > 3*PI/4:
					get_parent().rotation = PI
					reset_rotation = false
				elif actor_rotation <= 3*PI/4 and actor_rotation > PI/4:
					get_parent().rotation = sign(get_parent().rotation)*PI/2
					reset_rotation = false
				elif actor_rotation <= PI/4 and actor_rotation >= 0:
					get_parent().rotation = 0
					reset_rotation = false
				
			if patrol and get_parent()._velocity == Vector2.ZERO:
				direction = 1
				get_parent()._velocity = Vector2(direction * get_parent().speed.x, 0).rotated(get_parent().rotation)
		State.ENGAGE: # entered detection area and looking for player; saw player, starting action and/or chase
			if player != null:
				destination = aim()
			
			# if actor is to chase the player and the raycasting found the player, tell the actor to move in that direction
			if destination != Vector2.ZERO:
				if active_chase:
					var angle = (destination - get_parent().global_position).angle()
					get_parent()._velocity = Vector2(get_parent().speed.x, 0).rotated(angle)
				else:
					get_parent()._velocity = Vector2.ZERO
		#State.FOLLOW: # player just left line of sight or detection circle, follow using trail
			#if player != null:
				#destination = follow()
		_:
			pass
	
	if patrol and get_parent().is_on_wall():
		direction *= -1.0
		get_parent()._velocity.x = direction * get_parent().speed.x
		get_parent()._velocity.y = 0.0


# uses raycasting to find a connection between the actor and the player
func aim() -> Vector2:
	hit_pos = []
	var space_state = get_parent().get_world_2d().direct_space_state # snapshot of physics state in this frame
	
	# define the corners of the player extents so that the player can be found, even when only a corner is showing
	var player_extents = player.get_node('CollisionShape2D').shape.extents - Vector2(5, 5)
	var northwest = player.global_position - player_extents
	var southeast = player.global_position + player_extents
	var northeast = player.global_position + Vector2(player_extents.x, -player_extents.y)
	var southwest = player.global_position + Vector2(-player_extents.x, player_extents.y)
	
	# search through each of the positions on the player body to see if a ray can hit one of them
	for pos in [player.global_position, northwest, northeast, southeast, southwest]:
		var result = space_state.intersect_ray(get_parent().global_position, pos, [get_parent()], get_parent().collision_mask)
		if result: # if ray hit something
			hit_pos.append(result.position)
			if result.collider.is_in_group("player"):
				var parent_rotation = get_parent().rotation # current rotation angle
				var ray_rotation = (player.global_position - get_parent().global_position).angle() # angle to player
				#print(String(parent_rotation) + ":" + String(ray_rotation))
				var difference = fmod(ray_rotation - parent_rotation, 2*PI)
				if abs(fmod(2 * difference, 2*PI) - difference) < deg2rad(detection_angle/2): # if the player is within the detection angle in front of the actor
					var distance = pos.distance_to(get_parent().global_position)
					if distance < detection_radius:
						get_parent().rotation = lerp_angle(parent_rotation, ray_rotation, 0.1) # smoothly turn the actor towards the player
						# if an action has been defined for the actor (e.g. shoot_taser for EnemyGuard) then perform it
						if action and abs(get_parent().rotation - ray_rotation) < 0.1:
							action.call_func(pos)
						return pos
				break # first ray to hit a player remains as the only ray
	return Vector2.ZERO # to indicate no ray has hit the player


# functions to provide a smooth rotation from one position to the next
func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight


func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference


# draw the vision circle and rays from raytracing
func _draw() -> void:
	if ray_visual:
		draw_circle_arc_poly(Vector2.ZERO, detection_radius, -detection_angle/2, detection_angle/2, detection_color)
		if player:
			for hit in hit_pos:
				draw_circle((hit - get_parent().global_position).rotated(-get_parent().rotation), 5, laser_color)
				draw_line(Vector2(), (hit - get_parent().global_position).rotated(-get_parent().rotation), laser_color)


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = Array()
	points_arc.push_back(center)
	var colors = Array([color])

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / nb_points)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)


# on detection circle being entered, change to engage state (wait for line of sight then perform action and/or chase)
func _on_PlayerDetectionZone_body_entered(body: Node) -> void:
	# check if body is a Player
	if body.is_in_group("player"):
		set_state(State.ENGAGE)
		player = body


func _on_PlayerDetectionZone_body_exited(body: Node) -> void:
	# check if body is a Player
	if player and body.is_in_group("player"):
		set_state(State.PATROL)
		player = null
		reset_rotation = true
