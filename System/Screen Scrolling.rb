#==============================================================================
#** Quasi Screen Scrolling v2.0
#==============================================================================
# Better screen scrolling.
# Allows smooth diagonal scrolling
# Can also scroll to a player/event
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v2.0 - 11/12/14
#      - Rewriten/cleaned
#      - Added methods to game_interpreter for smaller scrip calls.
#      - Removed start_angled method.
# --
# v1.3 - 9/2/14
#      - Changed speed to work in pixels per frame.  Changed event map scroll 4 speed
#        to take 60 frames for the scroll, 1 speed is 8x slower, 2 is 4x slower, ect.
# --
# v1.2 - 9/2/14
#      - Changed how speed works, for better scrolling, may have to use script calls
#        instead of event scrolling for higher speeds.
# --
# v1.1 - 8/24/14
#      - Added $game_map.start_angled(angle, distance in pixels, speed)
#==============================================================================
#
# Instructions:
#
#------------------------------------------------------------------------------
#  * For Diagonal scroll you use the following script call:
#------------------------------------------------------------------------------
#    scroll(direction, distance, speed)
#
#     -Direction is equal to a number 1, 2, 3, 4, 6, 7, 8, or 9:
#        7 Up/Left      8 Up        9 Up/Right
#        4 Left                     6 Right
#        1 Down/Left    2 Down      3 Down/Right
#
#       (Can look at number pad for visual help.)
#
#     -Distance is the number of tiles you want to scroll
#      * For diagonal you need to place this in bracets [X, Y] and keep the values
#      possitive!
#
#     -Speed is how fast it should scroll
#      * Speed was changed to how many frames the scroll should take
#        ( 1 second = 60 frames )
#      * default speed 4 is equal to 60 frames, Speed 1: 8xSlower is 
#        8x slower then speed 4's 60 frames ( 60 * 8, so 480 frames or 8 seconds)
#
#  Example call:
#
#    scroll(7,[6,4],4)
#     *This will scroll up 4 tiles, and scroll left 6 tiles because direction is 7,
#      and it will take 60 frames because the speed is 4.
#
#------------------------------------------------------------------------------
#  * To scroll to an event or player, use the following script call:
#------------------------------------------------------------------------------
#    scroll_to(object, speed)
#
#    - object is the event id you want to scroll to!  
#      Place 0 if you want to scroll to the player.
#
#  Example calls:
#
#    scroll_to(0,4)
#     * will scroll back to the player
#
#    scroll_to(1,4)
#     * will scroll to event 1's location
#
#==============================================================================#
# ** NOTE **
#  diagonal scrolling may sometimes only scroll in one direction!  But that is
# because you are near the edge of the screen, and it can't scroll in the other
# direction!
#==============================================================================#
# By Quasi (http://quasixi.com/) || (https://github.com/quasixi/RGSS3)
#  - 8/13/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================
 
class Game_Map
  alias qsetup setup_scroll
  #--------------------------------------------------------------------------
  # * Scroll Setup
  #--------------------------------------------------------------------------
  def setup_scroll
    qsetup
    @slope_rest = 0
    @slope_speed = 0
    @scroll_rest2 = 0
    @scroll_speed2 = 0
  end
  #--------------------------------------------------------------------------
  # * Start Scroll
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
   
    distx = direction == 4 ? distance : direction == 6 ? distance : 0
    disty = direction == 8 ? distance : direction == 2 ? distance : 0
   
    @scroll_rest = distance.is_a?(Array) ? distance[0] : distx
    @scroll_rest2 = distance.is_a?(Array) ? distance[1] : disty
   
    check_scroll_limit(direction) if @scroll_rest2 != 0 && @scroll_rest != 0
   
    distance = Math.hypot(@scroll_rest, @scroll_rest2)
   
    @slope_rest = distance
    @slope_speed = distance / speed.to_f
   
    @scroll_speed =  @scroll_rest / speed.to_f
    @scroll_speed2 = @scroll_rest2 / speed.to_f
  end
  #--------------------------------------------------------------------------
  # * Checks if screen can scroll X/Y distance
  #   if not, get the dif.
  # ** Note sure if this works in v1.3
  #--------------------------------------------------------------------------
  def check_scroll_limit(dir)
    dif_x = @display_x + (@scroll_rest * (dir == 7 || dir == 1 ? -1 : 1))
    dif_y = @display_y + (@scroll_rest2 * (dir == 7 || dir == 9 ? -1 : 1))
    @scroll_rest = @display_x if dif_x < 0 && !loop_horizontal?
    @scroll_rest2 = @display_y if dif_y < 0 && !loop_vertical?
  end
  #--------------------------------------------------------------------------
  # * Determine if Scrolling
  #--------------------------------------------------------------------------
  def scroll_to(obj, speed)
    obj = obj == 0 ? $game_player : @events[obj]
   
    center_x = (@display_x+(Graphics.width/2)/32).round
    center_y = (@display_y+(Graphics.height/2)/32).round
   
    if loop_horizontal? && obj.x < @display_x - (width - screen_tile_x) / 2
      dist_x = obj.x - center_x + @map.width
    else
      dist_x = obj.x - center_x
    end
    if loop_vertical? && obj.y < @display_y - (height - screen_tile_y) / 2
      dist_y = obj.y - center_y + @map.height
    else
      dist_y = obj.y - center_y
    end
   
    x_dir = dist_x <=> 0
    y_dir = dist_y <=> 0
   
    return if x_dir == 0 && y_dir == 0
    dir = {1 => [-1, 1],  2 => [0, 1],  3 => [1, 1],  4 => [-1, 0],
           6 => [1, 0],  7 => [-1, -1],  8 => [0, -1],  9 => [1, -1]}
    dist = [dist_x.abs, dist_y.abs]
    dist = dist_y == 0 ? dist_x.abs : dist_x == 0 ? dist_y.abs : dist
    start_scroll(dir.key([x_dir, y_dir]), dist, speed)
  end
  #--------------------------------------------------------------------------
  # * Determine if Scrolling
  #--------------------------------------------------------------------------
  def scrolling?
    @slope_rest > 0
  end
  #--------------------------------------------------------------------------
  # * Update Scroll
  #--------------------------------------------------------------------------
  def update_scroll
    return unless scrolling?
    do_scroll(@scroll_direction, @scroll_speed, @scroll_speed2)
    @slope_rest = [0, @slope_rest - @slope_speed].max
  end
  #--------------------------------------------------------------------------
  # * Execute Scroll
  #--------------------------------------------------------------------------
  def do_scroll(direction, distance, distance2 = nil)
    case direction
    when 1, 2; scroll_left (distance); scroll_down(distance2)
    when 3, 6; scroll_right(distance); scroll_down(distance2)
    when 7, 4; scroll_left (distance); scroll_up  (distance2)
    when 9, 8; scroll_right(distance); scroll_up  (distance2)
    end
  end
end
 
#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================
 
class Game_Interpreter
  #--------------------------------------------------------------------------
  # *OVERWRITE* Scroll Map
  #--------------------------------------------------------------------------
  def command_204
    return if $game_party.in_battle
    Fiber.yield while $game_map.scrolling?
    speed = {1 => 8.0, 2 => 4.0, 3 => 2.0, 4 => 1, 5 => 1/2.0, 6 => 1/4.0}
    scroll(@params[0], @params[1], 60 * speed[@params[2]])
  end
  #--------------------------------------------------------------------------
  # * Scroll
  #--------------------------------------------------------------------------
  def scroll(direction, distance, speed)
    $game_map.start_scroll(direction, distance, speed)
  end
  #--------------------------------------------------------------------------
  # * Scroll to
  #--------------------------------------------------------------------------
  def scroll_to(obj, speed)
    $game_map.scroll_to(obj, speed)
  end
end
