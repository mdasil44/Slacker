extends KinematicBody2D # this script is going to have all the functionality of "KinematicBody2D"
class_name Actor

# : = sets variable on left side to the type on the right side
# Vector2(300, 300) want velocity of player to be 300 pixels per second in x and y directions
# export allows the user to adjust the variable through the Script Variables section of each object which uses this script (configurable)
export var speed: = Vector2(300.0,300.0) # max speed for each axis

# leading _ indicates private variable to only be used within the class
var _velocity: = Vector2.ZERO
