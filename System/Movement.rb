#==============================================================================
# ** Quasi Movement v1.0
#  Require Module Quasi
#   http://code.quasixi.com/page/post/quasi+module/
#==============================================================================
#  Changed how movement works.  Allows players to choose how many pixels to move
# per movement.  In better terms, allows players to make characters have a pixel
# movement or still by by a grid like 32x32 or even 16x16.
#  Changed how collisions work.  Events now have bounding boxes surrounding them.
# If two boxes touch there will be a collision.  Boxes can be set in each event,
# further detail in the instructions.
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v1.0 - 11/18/14
#      - Removed friction, will write as a seperate add-on.
#      - Added a few new bounding box methods
#        > vertices, edge, v_center
#      - Fixed qmove for forced movement routes (Set Move Route in events)
#      - Change random to work a smoother for smaller grid movements
#      - Added TileBoxes which are added in automatically
#        > Region boxes still priotize over Tiles!
#
# v0.8 - Changed movement speed back to vxa default
#      - Changed bbox comment box it is now:
#        <bbox:width,height,ox,oy> (just added the < >)
#      - Adjusted map passibility, still needs work
#        Region boxes work much better then tile passibilty.
#      - Added a mid move passibilty check for more accurate passibilty
#      - Added Region boxes (more on step 6)
#      - Added Region Friction (more on step 7) -REMOVED-
# --
# v0.7 - Pre-Released for feedback
#------------------------------------------------------------------------------
# To do / Upcoming
#------------------------------------------------------------------------------
# - Fix follower distance
# - Add a push out of box, if you somehow got inside a box with through off.
# - Find more bugs~
#==============================================================================
module Quasi
  module Movement
#------------------------------------------------------------------------------
# Instructions:
#  Step 1. Set GRID to the amount of pixels you want to move per movement.
#          Default is 1, meaning pixel movement.  This can be changed back
#          to 32 which is vxa default tile movement.
#------------------------------------------------------------------------------
    GRID = 1
#------------------------------------------------------------------------------
#  Step 2. Set DIR8 to true or false.  When true it will allow for 8 direction
#          movement, when false it will not.  Diagonal movement was modified
#          if the diagonal movement isn't possible it will attempt the two
#          directions seperatly to see if they work.
#         Example:  Player tries to move UP/RIGHT (Diag 9) but it's not passible
#                 Player will see if UP is passible, if it's not it will try
#                 RIGHT.  If neither work, player won't move
#------------------------------------------------------------------------------
    DIR8 = true
#------------------------------------------------------------------------------
#  Step 3. Set DIAGSPEED.  This adjusts the speed when moving diagonal.  Set to
#          0 if you want to stay at same speed, default at -0.5
#------------------------------------------------------------------------------
    DIAGSPEED = -0.5
#------------------------------------------------------------------------------
#  Step 4. Set PLAYERBOX.  This sets the bounding box for the player character.
#          by default it is [24,16,4,8] More details on setting bounding boxes
#          a few lines below.
#         - Events will also default to these values.
#------------------------------------------------------------------------------
    PLAYERBOX = [24,16,4,16]
#------------------------------------------------------------------------------
#  Step 5. -Bounding boxes-
#          How to set up on event:
#           Make a comment anywhere in the event with the following setup:
#              <bbox=width,height,ox,oy>
#           bbox=   :Starts the set up for the bounding box
#           width   :The width of the box, default 32
#           height  :The height of the box, default 32
#           ox      :The x orgin of the box, default is 0
#           oy      :The y orgin of the box, default is 0
#       
#          ox and oy can be left out, they will default to 0 if blank.
#          0 ox and oy means box starts from top left cornor of the event.
#       Example Boxes:
#              <bbox=32,32>
#         Creates the default box which is 32x32 starting at the top left, good
#         for block tiles.  Notice how ox and oy are left out.

#              <bbox=24,16,4,16>
#         Creates a box that is 24x16.  The box is pushed to the left 4 pixels
#         and down 16.  This is a good box for vxa characters that are 32x32.
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#  Step 6. REGION BOXES.  Theses give region bounding boxes.
#          Regions, unlike character boxes, can have multiple boxes.
#          They are set up like:
#           REGIONBOXES{
#            REGION NUMBER => [box parameters], # Single box
#            REGION NUMBER => [[box 1 parameters],[box 2 parameters]], # Multiple boxes
#           } # < ends the hash *Important!*
#
#         *NOTE*  Region boxes only work if you're inside the box, unlike event boxes
#           what this means is, you should not make the box go outside of the
#           region tile, can keep it within a 32x32 box.
#         *NOTE* Region boxes prioritize over tile passibilty,
#           so even if the tile is set to no direction, it will use
#           the region passibilty instead, if there's a region on that tile.
#------------------------------------------------------------------------------
    REGIONBOXES = {
      62 => [0, 0],
      63 => [32, 32]
    }
#------------------------------------------------------------------------------
#  For testing purposes, set the bottom value to true to see the boxes.
#  Only shows during play testing.
#  *Does not show region boxes!*
#------------------------------------------------------------------------------
    SHOWBOXES = true
#------------------------------------------------------------------------------
# DO NOT EDIT THESE UNLESS YOU KNOW WHAT YOU ARE DOING
#------------------------------------------------------------------------------
    TILEBOXES = {
      1544 => [32,4],
      1548 => [[32,4],[4,32,28]],
      1540 => [4,32,28],
      1541 => [[32,4,0,28],[4,32,28]],
      1546 => [[32,4],[4,32]],
      1538 => [4,32],
      1539 => [[32,4,0,28],[4,32]],
      1537 => [32,4,0,28],
      1551 => [32,32],
      3594 => [[32,4],[4,32]],
      3592 => [32,4],
      3596 => [[32,4],[4,32,28]],
      3588 => [4,32,28],
      3586 => [4,32],
      3599 => [32,32]
    }
  end
end
#==============================================================================#
# By Quasi (http://quasixi.com/) || (https://github.com/quasixi/RGSS3)
#  - 9/22/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
$imported = {} if $imported.nil?
$imported["Quasi_Movement"] = 1.0

if $imported["Quasi"]
#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This base class handles characters. It retains basic information, such as 
# coordinates and graphics, shared by all characters.
#==============================================================================

class Game_CharacterBase
  alias qm_init       init_public_members
  alias qm_moveto     moveto
  alias qm_update     update
  alias qm_straighten straighten
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :px            
  attr_reader   :py 
  attr_reader   :velocity
  #--------------------------------------------------------------------------
  # * Initialize Public Member Variables
  #--------------------------------------------------------------------------
  def init_public_members
    qm_init
    @px = 0
    @py = 0
    @npx = 0
    @npy = 0
    @velocity = 0
    @diag = false
    @grid = Quasi::Movement::GRID
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    x1 = d == 4 ? x-move_tiles : d == 6 ? x + move_tiles : x
    y1 = d == 8 ? y-move_tiles : d == 2 ? y + move_tiles : y
    x2 = $game_map.round_px(x1)
    y2 = $game_map.round_py(y1)
    x3 = $game_map.round_x((x1/32.0).round)
    y3 = $game_map.round_y((y1/32.0).round)
    
    return false unless $game_map.valid?(x3, y3)
    return true if @through || debug_through?
    return false unless midpassable?(x,y,d)
    return false unless map_passable?(x2, y2, d)
    return false if collide_with_box?(x2, y2)
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine if Midpoint is Passable
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def midpassable?(x, y, d)
    half_tiles = move_tiles/2.0
    x2 = $game_map.round_px_with_direction(x, d, half_tiles)
    y2 = $game_map.round_py_with_direction(y, d, half_tiles)
    
    return false unless map_passable?(x2, y2, d)
    return false unless map_passable?(x2, y2, reverse_dir(d))
    return false if collide_with_box?(x2, y2)
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine if Map is Passable
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def map_passable?(x, y, d)
    rbox = Quasi::Movement::REGIONBOXES.keys
    flags = $game_map.tileboxes
    edge = edge(x, y)[d]
    
    if rbox.include?($game_map.region_id(edge[0][0], edge[0][1])) || 
       rbox.include?($game_map.region_id(edge[1][0], edge[1][1]))
      regionpass?(edge[0][0], edge[0][1], x, y) && 
      regionpass?(edge[1][0], edge[1][1], x, y)
    elsif flags[edge[0][0], edge[0][1]] != 0 || 
          flags[edge[1][0], edge[1][1]] != 0
      regionpass?(edge[0][0], edge[0][1], x, y, true) && 
      regionpass?(edge[1][0], edge[1][1], x, y, true)
    else
      $game_map.passable?(edge[0][0], edge[0][1], d) && 
      $game_map.passable?(edge[1][0], edge[1][1], d)
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Diagonal Passability
  #     horz : Horizontal (4 or 6)
  #     vert : Vertical (2 or 8)
  #--------------------------------------------------------------------------
  def diagonal_passable?(x, y, horz, vert)
    x2 = $game_map.round_px_with_direction(x, horz, move_tiles)
    y2 = $game_map.round_py_with_direction(y, vert, move_tiles)
    (passable?(x, y, vert) &&  passable?(x, y2, horz)) ||
    (passable?(x, y, horz) &&  passable?(x2, y, vert))
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Character 
  #--------------------------------------------------------------------------
  def collide_with_box?(x, y)
    boxes = $game_map.bounding_xy(box_xy(x,y))
    if !boxes.empty?
      boxes.keep_if {|e| e != self}
    end
    !boxes.empty? || collide_with_vehicles?(x,y)
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Vehicle
  #--------------------------------------------------------------------------
  def collide_with_vehicles?(x, y)
    $game_map.boat.pos_nt?((x/32).round, (y/32).round) || 
    $game_map.ship.pos_nt?((x/32).round, (y/32).round)
  end
  #--------------------------------------------------------------------------
  # * Determine Triggering of Frontal Touch Event
  #--------------------------------------------------------------------------
  def check_event_trigger_touch_front
    x1 = $game_map.round_px_with_direction(@px, @direction, move_tiles)
    y1 = $game_map.round_py_with_direction(@py, @direction, move_tiles)
    check_event_trigger_touch(x1, y1)
  end
  #--------------------------------------------------------------------------
  # * Get Move Speed (Account for Dash)
  #--------------------------------------------------------------------------
  def real_move_speed
    @move_speed + (dash? ? 1 : 0) + (@diag ? Quasi::Movement::DIAGSPEED : 0)
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #--------------------------------------------------------------------------
  def moveto(x, y)
    @px = x * 32.0
    @py = y * 32.0
    @npx = @px
    @npy = @py
    qm_moveto(x,y)
  end
  #--------------------------------------------------------------------------
  # * How many tiles are you moving
  #--------------------------------------------------------------------------
  def move_tiles
    @grid < real_move_speed ? real_move_speed : @grid
  end
  def speed
    2**real_move_speed / 8.0
  end
  def moving?
    @velocity > 0
  end
  #--------------------------------------------------------------------------
  # * Update While Moving
  #--------------------------------------------------------------------------
  def update_move
    @px = [@px - speed, @npx].max if @npx < @px
    @px = [@px + speed, @npx].min if @npx > @px
    @py = [@py - speed, @npy].max if @npy < @py
    @py = [@py + speed, @npy].min if @npy > @py
    
    @real_x = @px/32.0 if @real_x != @px/32.0
    @real_y = @py/32.0 if @real_y != @py/32.0
    @x = @px/32.0 if @x != @px/32.0
    @y = @py/32.0 if @y != @py/32.0
    
    @velocity -= speed
    
    update_bush_depth unless moving?
  end
  #--------------------------------------------------------------------------
  # * Move Straight
  #     d:        Direction (2,4,6,8)
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    @move_succeed = passable?(@px, @py, d)
    orginal_speed = @move_speed
    if !@move_succeed && self.is_a?(Game_Player)
      while !@move_succeed
        break if @move_speed < 1
        @move_speed -= 0.5
        @move_succeed = passable?(@px, @py, d)
      end
    end
    if @move_succeed
      set_direction(d)
      @diag = false
      @velocity = move_tiles
      @npx = $game_map.round_px_with_direction(@px, d, move_tiles)
      @npy = $game_map.round_py_with_direction(@py, d, move_tiles)
      @px = $game_map.px_with_direction(@npx, reverse_dir(d), move_tiles)
      @py = $game_map.py_with_direction(@npy, reverse_dir(d), move_tiles)
      increase_steps
    elsif turn_ok
      set_direction(d)
      check_event_trigger_touch_front
    end
    @move_speed = orginal_speed
    @velocity = 0 if !@move_succeed
  end
  #--------------------------------------------------------------------------
  # * Move Diagonally
  #     horz:  Horizontal (4 or 6)
  #     vert:  Vertical (2 or 8)
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    @move_succeed = diagonal_passable?(@px, @py, horz, vert)
    orginal_speed = @move_speed
    if !@move_succeed && self.is_a?(Game_Player)
      while !@move_succeed
        break if @move_speed < 1
        @move_speed -= 0.5
        @move_succeed = diagonal_passable?(@px, @py, horz, vert)
      end
    end
    if @move_succeed
      @diag = true
      @velocity = move_tiles
      @npx = $game_map.round_px_with_direction(@px, horz, move_tiles)
      @npy = $game_map.round_py_with_direction(@py, vert, move_tiles)
      @px = $game_map.px_with_direction(@npx, reverse_dir(horz), move_tiles)
      @py = $game_map.py_with_direction(@npy, reverse_dir(vert), move_tiles)
      increase_steps
    end
    @move_speed = orginal_speed
    set_direction(horz) if @direction == reverse_dir(horz)
    set_direction(vert) if @direction == reverse_dir(vert)
    if !@move_succeed
      if passable?(@px, @py, horz)
        move_straight(horz)
      elsif passable?(@px, @py, vert)
        move_straight(vert)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Bounding box array
  #--------------------------------------------------------------------------
  def bounding_box
    return @boundingbox if @boundingbox
    @boundingbox = [32,32,0,0]
  end
  #--------------------------------------------------------------------------
  # * Make Bounding box
  #--------------------------------------------------------------------------
  def box_xy(x=@px,y=@py)
    bb = bounding_box
    ox = bb[2].nil? ? 0 : bb[2]
    oy = bb[3].nil? ? 0 : bb[3]
    oy -= shift_y
    bx = x+ox..x+bb[0]+ox
    by = y+oy..y+bb[1]+oy
    return [bx, by]
  end
  #--------------------------------------------------------------------------
  # * Check for Bounding box Collision
  #  Returns true if boxes are inside each other.
  #--------------------------------------------------------------------------
  def box?(objbox, through=nil)
    through = through.nil? ? @through : through
    return if !bounding_box || through
    pass1 = (objbox[0].first <= box_xy[0].last) && (objbox[0].last >= box_xy[0].first)
    pass2 = (objbox[1].first <= box_xy[1].last) && (objbox[1].last >= box_xy[1].first)
    return pass1 && pass2
  end
  #--------------------------------------------------------------------------
  # * Find the boxes vertices
  # returns array [top left, top right, bottom left, bottom right]
  #--------------------------------------------------------------------------
  def vertices(x=@px, y=@py)
    x1 = box_xy(x, y)[0]
    y1 = box_xy(x, y)[1]
    tl = [x1.first, y1.first]
    tr = [x1.last, y1.first]
    bl = [x1.first, y1.last]
    br = [x1.last, y1.last]
    return [tl, tr, bl, br]
  end
  #--------------------------------------------------------------------------
  # * Find facing edge in 32 grid terms
  #--------------------------------------------------------------------------
  def edge(x=@px, y=@py)
    x1 = box_xy(x, y)[0]
    y1 = box_xy(x, y)[1]
    tl = [(x1.first/32.0).truncate,(y1.first/32.0).truncate]
    tr = [(x1.last/32.0).truncate,(y1.first/32.0).truncate]
    bl = [(x1.first/32.0).truncate,(y1.last/32.0).truncate]
    br = [(x1.last/32.0).truncate,(y1.last/32.0).truncate]
    return {2 => [bl, br], 4 => [tl, bl], 6 => [tr, br], 8 => [tl, tr]}
  end
  #--------------------------------------------------------------------------
  # * Find center of box
  #--------------------------------------------------------------------------
  def v_center(x=@px, y=@py)
    x1 = box_xy(x, y)[0]
    y1 = box_xy(x, y)[1]
    mx = x1.first + ((x1.last - x1.first) / 2.0)
    my = y1.first + ((y1.last - y1.first) / 2.0)
    return [mx, my]
  end
  #--------------------------------------------------------------------------
  # * Makes region box (Should probably be in game_map)
  #--------------------------------------------------------------------------
  def regbox(x, y, flag = nil)
    bb = Quasi::Movement::REGIONBOXES[$game_map.region_id(x, y)]
    bb = Quasi::Movement::TILEBOXES[$game_map.tileboxes[x, y]] if flag
    return if !bb
    regbox = []
    if bb[0].is_a?(Array)
      bb.each do |box|
        x1 = x * 32; y1 = y * 32
        ox = box[2].nil? ? 0 : box[2]
        oy = box[3].nil? ? 0 : box[3]
        bx = x1 + ox..x1 + box[0] + ox
        by = y1 + oy..y1 + box[1] + oy
        regbox << [bx, by]
      end
    else
      x1 = x * 32; y1 = y * 32
      ox = bb[2].nil? ? 0 : bb[2]
      oy = bb[3].nil? ? 0 : bb[3]
      bx = x1 + ox..x1 + bb[0] + ox
      by = y1 + oy..y1 + bb[1] + oy
      regbox = [bx, by]
    end
    return regbox
  end
  #--------------------------------------------------------------------------
  # * Region box Collision
  #  Makes region box then passes it through a check.
  #  Returns true if region is passable ( No box collision. )
  #--------------------------------------------------------------------------
  def regionpass?(x, y, nx, ny, flag = nil)
    bb = regbox(x, y, flag)
    return true if !bb || @through
    if bb[0].is_a?(Array)
      pass = []
      bb.each do |box|
        pass << regbox?(box, nx, ny)
      end
      return pass.count(false) == pass.size 
    else
      return regbox?(bb, nx, ny) == false
    end
  end
  #--------------------------------------------------------------------------
  # * Returns true if boxes are inside each other.
  #--------------------------------------------------------------------------
  def regbox?(rbox, nx, ny)
    box = box_xy(nx, ny)
    insidex = (box[0].last >= rbox[0].first) && (box[0].first <= rbox[0].last)
    insidey = (box[1].last >= rbox[1].first) && (box[1].first <= rbox[1].last)
    return insidex && insidey
  end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  alias qmove_gm_setup setup
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(map_id)
    qmove_gm_setup(map_id)
    @tileboxes = Table.new(width, height)
    setup_tileboxes
  end
  #--------------------------------------------------------------------------
  # * Calculate PX Coordinate After Loop Adjustment
  #--------------------------------------------------------------------------
  def round_px(x)
    loop_horizontal? ? (x + (width*32)) % (width*32) : x
  end
  #--------------------------------------------------------------------------
  # * Calculate PY Coordinate After Loop Adjustment
  #--------------------------------------------------------------------------
  def round_py(y)
    loop_vertical? ? (y + (height*32)) % (height*32) : y
  end
  #--------------------------------------------------------------------------
  # * Calculate PX Coordinate Shifted One Tile in Specific Direction
  #   (No Loop Adjustment)
  #--------------------------------------------------------------------------
  def px_with_direction(x, d, v)
    x + (d == 6 ? v : d == 4 ? -v : 0)
  end
  #--------------------------------------------------------------------------
  # * Calculate PY Coordinate Shifted One Tile in Specific Direction
  #   (No Loop Adjustment)
  #--------------------------------------------------------------------------
  def py_with_direction(y, d, v)
    y + (d == 2 ? v : d == 8 ? -v : 0)
  end
  #--------------------------------------------------------------------------
  # * Calculate PX Coordinate Shifted One Pixel in Specific Direction
  #   (With Loop Adjustment)
  #--------------------------------------------------------------------------
  def round_px_with_direction(x, d, v)
    round_px(x + (d == 6 ? v : d == 4 ? -v : 0))
  end
  #--------------------------------------------------------------------------
  # * Calculate PY Coordinate Shifted One Pixel in Specific Direction
  #   (With Loop Adjustment)
  #--------------------------------------------------------------------------
  def round_py_with_direction(y, d, v)
    round_py(y + (d == 2 ? v : d == 8 ? -v : 0))
  end
  #--------------------------------------------------------------------------
  # * Get Array of Event Bounding Box at Designated Coordinates
  #--------------------------------------------------------------------------
  def bounding_xy(objbox,through=nil)
    @events.values.select {|event| event.box?(objbox,through) }
  end
  #--------------------------------------------------------------------------
  # * Setup Passibilities
  #--------------------------------------------------------------------------
  def setup_tileboxes
    for x in 0..width
      for y in 0..height
        all_tiles(x, y).each do |tile_id|
          flag = tileset.flags[tile_id]
          next if flag & 0x10 != 0
          next unless Quasi::Movement::TILEBOXES[flag] 
          @tileboxes[x, y] = flag
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Grab Passibilities
  #--------------------------------------------------------------------------
  def tileboxes
    return @tileboxes if @tileboxes
  end
end

#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  A character class with mainly movement route and other such processing
# added. It is used as a super class of Game_Player, Game_Follower,
# GameVehicle, and Game_Event.
#==============================================================================

class Game_Character < Game_CharacterBase
  alias qmgc_force force_move_route
  #--------------------------------------------------------------------------
  # * Force Move Route
  #--------------------------------------------------------------------------
  def force_move_route(move_route)
    qmgc_force(move_route)
    sub_qmove
  end
  #--------------------------------------------------------------------------
  # * Replace qmove() with real moves
  #--------------------------------------------------------------------------
  def sub_qmove
    move = { 2 => ROUTE_MOVE_DOWN,     4 => ROUTE_MOVE_LEFT,
             6 => ROUTE_MOVE_RIGHT,    8 => ROUTE_MOVE_UP,
             1 => ROUTE_MOVE_LOWER_L,  3 => ROUTE_MOVE_LOWER_R,
             7 => ROUTE_MOVE_UPPER_L,  9 => ROUTE_MOVE_UPPER_R  }
    @move_route.list.each_with_index do |list, i|
      next unless list.parameters[0] =~ /qmove/
      qmove =  list.parameters[0].delete "qmove()"
      qmove = qmove.split(",").map {|s| s.to_i}
      (qmove[1]/real_move_speed).times do
        @move_route.list.insert(i+1, RPG::MoveCommand.new(move[qmove[0]]))
      end
    end
    @move_route.list.delete_if {|list| list.parameters[0] =~ /qmove/ }
    memorize_move_route
  end
  #--------------------------------------------------------------------------
  # * Filler method
  #--------------------------------------------------------------------------
  def qmove(dir, steps)
  end
  alias qmgc_process process_move_command
  #--------------------------------------------------------------------------
  # * Process Move Command
  #--------------------------------------------------------------------------
  def process_move_command(command)
    qmgc_process(command)
    params = command.parameters
    case command.code
    when :reset;  qreset(params[0])
    end
  end
  #--------------------------------------------------------------------------
  # * Move at Random
  #--------------------------------------------------------------------------
  def move_random
    dir = qrand(1..4)
    dir = qrand(1..9) if Quasi::Movement::DIR8
    while dir == 5
      dir = qrand(1..9) if Quasi::Movement::DIR8
    end
    move = { 2 => ROUTE_MOVE_DOWN,     4 => ROUTE_MOVE_LEFT,
             6 => ROUTE_MOVE_RIGHT,    8 => ROUTE_MOVE_UP,
             1 => ROUTE_MOVE_LOWER_L,  3 => ROUTE_MOVE_LOWER_R,
             7 => ROUTE_MOVE_UPPER_L,  9 => ROUTE_MOVE_UPPER_R  }
    amt = [(qrand(6..32)) - Quasi::Movement::GRID, 1].max
    amt = (amt/real_move_speed).round
    amt.times do
      @move_route.list.insert(@move_route_index+1, RPG::MoveCommand.new(move[dir]))
    end
    last = @move_route_index + amt + 1
    @move_route.list.insert(last, RPG::MoveCommand.new(:reset, [@move_route_index+1]))
  end
  #--------------------------------------------------------------------------
  # * QReset
  #--------------------------------------------------------------------------
  def qreset(backto)
    @move_route.list.each {|list| p list}
    backtrack = @move_route_index - backto + 1
    backtrack.times do
      @move_route.list.delete_at(backto)
    end
    @move_route_index = backto - 1
    p "-"
    @move_route.list.each {|list| p list}
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class handles events. Functions include event page switching via
# condition determinants and running parallel process events. Used within the
# Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  alias qme_setup setup_page_settings
  #--------------------------------------------------------------------------
  # * Detect Collision with Character 
  #--------------------------------------------------------------------------
  def collide_with_box?(x, y)
    super || collide_with_player_characters?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Player (Including Followers)
  #--------------------------------------------------------------------------
  def collide_with_player_characters?(x, y)
    normal_priority? && $game_player.box?(box_xy(x,y))
  end
  #--------------------------------------------------------------------------
  # * Determine if Touch Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    return if $game_map.interpreter.running?
    if @trigger == 2 && $game_player.box?(box_xy(x,y), false)
      start if !jumping? && normal_priority?
    end
  end
  #--------------------------------------------------------------------------
  # * Bounding box
  #--------------------------------------------------------------------------
  def bounding_box
    return @boundingbox if @boundingbox
    pb = Quasi::Movement::PLAYERBOX
    dimension = grab_comment(/<bbox=(.*)>/i, "#{pb[0]},#{pb[1]},#{pb[2]},#{pb[3]}")
    @boundingbox = dimension.split(",").map {|s| s.to_i}
  end
  #--------------------------------------------------------------------------
  # * Set Up Event Page Settings
  #--------------------------------------------------------------------------
  def setup_page_settings
    qme_setup
    sub_qmove
  end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. It includes event starting determinants and
# map scrolling functions. The instance of this class is referenced by
# $game_player.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Processing of Movement via Input from Directional Buttons
  #--------------------------------------------------------------------------
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    if Quasi::Movement::DIR8
      if Input.dir8 > 0
        dia = {7 => [4,8], 1 => [4,2], 9 => [6,8], 3 => [6,2]}
        if [1,7,9,3].include?(Input.dir8)
          move_diagonal(dia[Input.dir8][0], dia[Input.dir8][1])
        else
          move_straight(Input.dir8)
        end
      end
    else
      move_straight(Input.dir4) if Input.dir4 > 0
    end
  end
  #--------------------------------------------------------------------------
  # * Trigger Map Event
  #     triggers : Trigger array
  #     normal   : Is priority set to [Same as Characters] ?
  #--------------------------------------------------------------------------
  def start_map_event(x, y, triggers, normal)
    return if $game_map.interpreter.running?
    $game_map.bounding_xy(box_xy(x,y),false).each do |event|
      if event.trigger_in?(triggers) && event.normal_priority? == normal
        event.start
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Same Position Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    start_map_event(@px, @py, triggers, false)
  end
  #--------------------------------------------------------------------------
  # * Determine if Front Event is Triggered
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    d = @direction
    x1 = d == 4 ? @px-move_tiles : d == 6 ? @px+move_tiles : @px
    y1 = d == 8 ? @py-move_tiles : d == 2 ? @py+move_tiles : @py
    x2 = $game_map.round_x((x1 / 32.0).round)
    y2 = $game_map.round_y((y1 / 32.0).round)
    start_map_event(x1, y1, triggers, true)
    
    return if $game_map.any_event_starting?
    x3 = d == 4 ? x1-move_tiles : d == 6 ? x1+move_tiles : x1
    y3 = d == 8 ? y1-move_tiles : d == 2 ? y1+move_tiles : y1
    x4 = $game_map.round_x((x3 / 32.0).round)
    y4 = $game_map.round_y((y3 / 32.0).round)
    start_map_event(x3, y3, triggers, true)
  end
  #--------------------------------------------------------------------------
  # * Move Straight
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    @followers.move if passable?(@px, @py, d)
    super
  end
  #--------------------------------------------------------------------------
  # * Move Diagonally
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    @followers.move if diagonal_passable?(@px, @py, horz, vert)
    super
  end
  #--------------------------------------------------------------------------
  # * Bounding box
  #--------------------------------------------------------------------------
  def bounding_box
    return @boundingbox if @boundingbox
    @boundingbox = Quasi::Movement::PLAYERBOX
  end
end

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes an instance of the
# Game_Character class and automatically changes sprite state.
#==============================================================================

class Sprite_Character < Sprite_Base
  alias qbox_init initialize
  alias qbox_update update
  alias qbox_dispose dispose
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     character : Game_Character
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    qbox_init(viewport, character)
    start_box if Quasi::Movement::SHOWBOXES && $TEST
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    qbox_update
    update_box if Quasi::Movement::SHOWBOXES
  end
  #--------------------------------------------------------------------------
  # * Start Box Display
  #--------------------------------------------------------------------------
  def start_box
    if @character.is_a?(Game_Follower)
      return unless @character.visible?
    end
    return if @character.transparent
    @box_sprite = Sprite.new(viewport)
    bb = @character.bounding_box
    bbox = bb[2].nil? ? 0 : bb[2]
    bboy = bb[3].nil? ? 0 : bb[3]
    @box_sprite.bitmap = Bitmap.new(bb[0],bb[1])
    @box_sprite.bitmap.fill_rect(@box_sprite.bitmap.rect,Color.new(255,0,0,255))
    @box_sprite.ox += 16 - bbox
    @box_sprite.oy += 32 - bboy
    @box_sprite.x = @character.x
    @box_sprite.y = @character.y
    @box_sprite.z = z
    @box_sprite.blend_type = 1
  end
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  def dispose
    qbox_dispose
    dispose_box if Quasi::Movement::SHOWBOXES 
  end
  #--------------------------------------------------------------------------
  # * Free Box
  #--------------------------------------------------------------------------
  def dispose_box
    @box_sprite.dispose if @box_sprite
  end
  #--------------------------------------------------------------------------
  # * Update Box
  #--------------------------------------------------------------------------
  def update_box
    return unless @box_sprite
    @box_sprite.x = x if @box_sprite.x != x 
    @box_sprite.y = y if @box_sprite.y != y
  end
end
else
  msgbox(sprintf("[Quasi Movement] Requires Quasi module."))
end
