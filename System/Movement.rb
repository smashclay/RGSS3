#==============================================================================
# ** Quasi Movement v1.2.1
#  Require Module Quasi [version 0.4.4 +]
#   http://code.quasixi.com/page/post/quasi+module/
#==============================================================================
#  Changed how movement works.  Allows players to choose how many pixels to move
# per movement.  In better terms, allows players to make characters have a pixel
# movement or still by by a grid like 32x32 or even 16x16.
#  Changed how collisions work.  Events now have bounding boxes surrounding them.
# If two boxes touch there will be a collision.  Boxes can be set in each event,
# further detail in the instructions.
#==============================================================================
# How to install:
#  - Place this below Module Quasi (link is above)
#  - Make sure the version of Module Quasi is the required version.
#  - Follow instructions below
#
# Extra instructions + Bounding box setup help at:
#  http://code.quasixi.com/page/post/movement/
#==============================================================================
module Quasi
  module Movement
#------------------------------------------------------------------------------
# Setup:
#    GRID to the amount of pixels you want to move per movement.
#  Default is 1, meaning pixel movement.  This can be changed back
#  to 32 which is vxa default tile movement.
#------------------------------------------------------------------------------
    GRID      = 1
#------------------------------------------------------------------------------
# Optimizing settings:
#  SMARTMOVE
#      If the move didn't succeed it will try again at lower speeds until
#    speed reaches 0.  This should only be used at lower grids like 1.
#      If movement fails it will attempt additional similar movements.
#  Values:
#    false   to disable
#    :speed  tries different speeds if move failed
#    :dir    tries different similiar directions if move failed (DIR8 needs to be true)
#    :both   both :speed and :dir
#------------------------------------------------------------------------------
    SMARTMOVE = :both
#------------------------------------------------------------------------------
#  MIDPASS
#      An extra collision check for the midpoint of the movement.  Should be
#    be used in larger grids if you have small boxes that can be skipped over
#    at certain speeds.
#    (Default passibilty only checks if you collided with anything at the point
#     you moved to, not anything inbetween)
#------------------------------------------------------------------------------
    MIDPASS   = false
#------------------------------------------------------------------------------
#    Set DIR8 to true or false.  When true it will allow for 8 direction
#  movement, when false it will not.
#  (This does not include an 8 direction frame)
#------------------------------------------------------------------------------
    DIR8      = true
#------------------------------------------------------------------------------
#    DIAGSPEED.  This adjusts the speed when moving diagonal.  Set to
#  0 if you want to stay at same speed.  Floats and negative values
#  are allowed.  
#    Ex: 0.5 and -0.5
#------------------------------------------------------------------------------
    DIAGSPEED = 0
#------------------------------------------------------------------------------
#    Set PLAYERBOX and EVENTBOX.  This sets the bounding box for the 
#  player character or event.
#    Good box for small grid( like GRID = 1):   [24, 16, 4, 16]
#    Good box for bigger grid( like GRID = 32): [22, 22, 5, 9]
#
#  Each actor can have their own bounding box by setting up a
#  bounding box inside the actors note tag.
#------------------------------------------------------------------------------
    PLAYERBOX = [24, 16, 4, 16]
    EVENTBOX  = [24, 16, 4, 16]
    VEHICLES  = {
      :boat     => [22, 22, 5, 9],
      :ship     => [22, 22, 5, 9],
      :airship  => [22, 22, 5, 9]
    }
#------------------------------------------------------------------------------
# REGION BOXES  
#    These give region bounding boxes.
#  Regions, unlike character boxes, can have multiple boxes.
#  They are set up like:
#    REGIONBOXES{
#      REGION NUMBER => [box parameters], # Single box
#      REGION NUMBER => [[box 1 parameters],[box 2 parameters]], # Multiple boxes
#    } # < ends the hash *Important!*
#
# *NOTE* 
#   Region boxes prioritize over tile passibilty, so even if the tile is set 
# to no direction, it will use the region passibilty instead, if there is 
# a region on that tile.
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
    SHOWBOXES   = true
    BOXBLEND    = 0
    BOXCOLOR    = Color.new(255, 0, 0, 120)
#------------------------------------------------------------------------------
# **DO NOT EDIT THESE UNLESS YOU KNOW WHAT YOU ARE DOING
#------------------------------------------------------------------------------
    TILEBOXES = {
      1537 => [32, 4, 0, 28],
      1538 => [4, 32],
      1539 => [[32, 4, 0, 28], [4, 32]],
      1540 => [4, 32, 28],
      1541 => [[32, 4, 0, 28], [4, 32, 28]],
      1544 => [32, 4],
      1546 => [[32, 4], [4, 32]],
      1548 => [[32, 4], [4, 32, 28]],
      1551 => [32, 32],
      2063 => [32, 32],
      2575 => [32, 32],
      3586 => [4, 32],
      3588 => [4, 32, 28],
      3590 => [[4, 32], [4, 32, 28]],
      3592 => [32, 4],
      3594 => [[32, 4], [4, 32]],
      3596 => [[32, 4], [4, 32, 28]],
      3598 => [[32, 4], [4, 32], [4, 32, 28]],
      3599 => [32, 32],
      3727 => [32, 32]
    }
  end
end
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v1.2.1 - 12/23/14
#      - Fixed some disposing problems with showbox
# v1.2 - 12/19/14
#      - Events face right direction when talked too
#      - Vehicle getting on / off fixed
#      - Tile (0, 0) impassibile was fixed
#      - Prepared for diagonal direction sprite script
#      - Fix for Map Vertical/Horizontal Scroll
#      - Fix for negative value ox / oy values for boxes
#      - Counters now work
#      - Initial x / y offset functions
#      - MidPass fix for larger grid
# --
# v1.16 - 12/6/14
#      - Changed @events.values to a method called map_events
#         this should allow easy compatibility patch with other anti lag
# --
# v1.15 - 12/6/14
#      - Added some vehicle support
#      - Fixed followers to straighten when following
#      - Fixed random move
#      - Above/Below priority are fixed
# --
# v1.1 - 11/27/14
#      - Added some missing tileboxes
#      - Tileboxes now created on map load, instead of when stepping on tile
#      - Tileboxes are now visible with SHOWBOXES settings
#      - Some SHOWBOXES settings ( blend type and color )
#      - 2 New options to help reduce lag
#        SMARTMOVE
#         - If move didn't succed it will keep trying at lower speeds, until
#           speed reaches 0.
#         * Should be used only with pixel movement (GRID = 1)
#        MIDPASS
#         - Checks if the midpoint for the move is passable
#           Small/Thin boxes can be skipped over depending on the
#           Characters box and grid movement
#           (You should avoid giving events/charas small boxes at higher grid)
#         * Should only be used with grid movement like 32
#      - Seperate default box option for events
#      - New bounding box comment for events, allows for different box
#        based on direction.
#      - Began to fix followers, distance is fixed.
#      - Fixed Turn/Move Towards/Away from character + added diagonal movement
#        if its turned on.
# --
# v1.0 - 11/18/14
#      - Removed friction, will write as a seperate add-on.
#      - Added a few new bounding box methods
#        > vertices, edge, v_center
#      - Fixed qmove for forced movement routes (Set Move Route in events)
#      - Change random to work a smoother for smaller grid movements
#      - Added TileBoxes which are added in automatically
#        > Region boxes still priotize over Tiles!
# --
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
# - Find more bugs
# - Make a pathfinder that works with this
#==============================================================================
#==============================================================================#
# By Quasi (http://quasixi.com/) || (https://github.com/quasixi/RGSS3)
#  - 9/22/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
$imported = {} if $imported.nil?
$imported["Quasi"] = 0 if $imported["Quasi"].nil?
$imported["Quasi_Movement"] = 1.21

if $imported["Quasi"] >= 0.43
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  alias :qm_gm_setup    :setup
  def setup(map_id)
    qm_gm_setup(map_id)
    @tileboxes = Array.new(width) { Array.new(height) { nil } }
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
  # * Calculate PX Coordinate Before Loop Adjustment
  #--------------------------------------------------------------------------
  def unround_px(x)
    x > (width-1)*32 ? x - (width*32) : x
  end
  #--------------------------------------------------------------------------
  # * Calculate PY Coordinate Before Loop Adjustment
  #--------------------------------------------------------------------------
  def unround_py(y)
    y > (height-1)*32 ? y - (height*32) : y
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
  def bounding_xy(objbox, through=nil)
    map_events.select {|event| event.box?(objbox, through) }
  end
  #--------------------------------------------------------------------------
  # * Get events on map
  #--------------------------------------------------------------------------
  def map_events
    return @events.values
  end
  #--------------------------------------------------------------------------
  # * Setup Passibilities
  #--------------------------------------------------------------------------
  def setup_tileboxes
    for x in 0...width
      for y in 0...height
        all_tiles(x, y).each do |tile_id|
          flag = tileset.flags[tile_id]
          if Quasi::Movement::REGIONBOXES.keys.include?(region_id(x, y))
            @tileboxes[x][y] = tilebox(x, y, region_id(x, y))
          else
            next if flag & 0x10 != 0
            next unless Quasi::Movement::TILEBOXES[flag] 
            next if @tileboxes[x][y]
            @tileboxes[x][y] = tilebox(x, y, flag, true)
          end
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Makes region/tile boxes
  # Tiles on edges are made twice when there is scroll loop
  #--------------------------------------------------------------------------
  def tilebox(x, y, id, tile=false)
    bb = Quasi::Movement::REGIONBOXES[id]
    bb = Quasi::Movement::TILEBOXES[id] if tile
    return if !bb
    tilebox = []
    tilebox = make_tilebox(bb, id, x, y)
    if x == 0 && loop_horizontal?
      tilebox = [tilebox, make_tilebox(bb, id, width, y)]
    elsif y == 0 && loop_vertical?
      tilebox = [tilebox, make_tilebox(bb, id, x, height)]
    end
    return tilebox
  end
  #--------------------------------------------------------------------------
  # * Makes the box
  #--------------------------------------------------------------------------
  def make_tilebox(bb, id, x, y)
    tilebox = []
    if bb[0].is_a?(Array)
      bb.each do |box|
        x1 = x * 32; y1 = y * 32
        ox = box[2].nil? ? 0 : box[2]
        oy = box[3].nil? ? 0 : box[3]
        bx = x1 + ox..x1 + box[0] + ox
        by = y1 + oy..y1 + box[1] + oy
        tilebox << [bx, by, id]
      end
    else
      x1 = x * 32; y1 = y * 32
      ox = bb[2].nil? ? 0 : bb[2]
      oy = bb[3].nil? ? 0 : bb[3]
      bx = x1 + ox..x1 + bb[0] + ox
      by = y1 + oy..y1 + bb[1] + oy
      tilebox = [bx, by, id]
    end
    return tilebox
  end
  #--------------------------------------------------------------------------
  # * Grab Passibilities
  #--------------------------------------------------------------------------
  def tileboxes
    return @tileboxes if @tileboxes
  end
  #--------------------------------------------------------------------------
  # * Check if tile has counter flag
  #--------------------------------------------------------------------------
  def tilecounter?(x, y)
    tile = @tileboxes[x][y]
    return unless tile
    if tile[0].is_a?(Array)
      return tile.any? {|box| box[2] == 3727}
    else
      return tile[2] == 3727
    end
  end
end

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This base class handles characters. It retains basic information, such as 
# coordinates and graphics, shared by all characters.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :px            
  attr_reader   :py 
  #--------------------------------------------------------------------------
  # * Initialize Public Member Variables
  #--------------------------------------------------------------------------
  alias :qm_gcb_init    :init_public_members
  def init_public_members
    qm_gcb_init
    @px = @py = @npx = @npy = @velocity = 0
    @diagonal = false
    @grid = Quasi::Movement::GRID
    init_quasi_variables
  end
  #--------------------------------------------------------------------------
  # * Initialize Quasi Movement setting variables
  #--------------------------------------------------------------------------
  def init_quasi_variables
    smart = Quasi::Movement::SMARTMOVE
    @smartmove = {
      :speed => smart == :speed || smart == :both,
      :dir   => smart == :dir || smart == :both
    }
    @dir4_diag = {
      8 => [[4, 8], [6, 8]],
      6 => [[6, 8], [6, 2]],
      2 => [[4, 2], [6, 2]],
      4 => [[4, 8], [4, 2]]
    }
    @dir8 = {
      9 => [6, 8],    7 => [4, 8],
      3 => [6, 2],    1 => [4, 2]
    }
    @dir8sprites = Quasi::Sprite::DIR8SPRITES if $imported["Quasi_Sprite"]
  end
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     d : Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    x1 = d == 4 ? x - move_tiles : d == 6 ? x + move_tiles : x
    y1 = d == 8 ? y - move_tiles : d == 2 ? y + move_tiles : y
    x2 = $game_map.round_px(x1)
    y2 = $game_map.round_py(y1)
    x3 = $game_map.round_x((x1/32.0).round)
    y3 = $game_map.round_y((y1/32.0).round)
    return false unless $game_map.valid?(x3, y3)
    return true if @through || debug_through?
    return false unless midpassable?(x, y, d) if Quasi::Movement::MIDPASS
    return false unless tilebox_passable?(x2, y2, d)
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
    return false unless tilebox_passable?(x2, y2, d) && 
      tilebox_passable?(x2, y2, reverse_dir(d))
    return false if collide_with_box?(x2, y2)
    return true
  end
  #--------------------------------------------------------------------------
  # * Determine if Tile is Passable
  #--------------------------------------------------------------------------
  def tilebox_passable?(x, y, d)
    edge = edge32(x, y, d)
    tilepass?(edge[0][0], edge[0][1], x, y) && 
    tilepass?(edge[1][0], edge[1][1], x, y)
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
    x2 = $game_map.unround_px(x)
    y2 = $game_map.unround_py(y)
    looped = $game_map.loop_horizontal? || $game_map.loop_vertical?
    boxes = $game_map.bounding_xy(box_xy(x, y))
    if looped && (x2 != x || y2 != y)
      boxes += $game_map.bounding_xy(box_xy(x2, y2)) 
    end
    unless boxes.empty?
      boxes.keep_if {|e| e != self && e.normal_priority?}
    end
    !boxes.empty? || collide_with_vehicles?(x, y)
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Vehicle
  #--------------------------------------------------------------------------
  def collide_with_vehicles?(x, y)
    $game_map.boat.box?(box_xy(x,y)) ||
    $game_map.ship.box?(box_xy(x,y))
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
  # * Make Bounding box
  #--------------------------------------------------------------------------
  def box_xy(x=@px, y=@py)
    bb = bounding_box
    if bb.is_a?(Hash)
      bb = bb["dir#{direction}".to_sym] ? bb["dir#{direction}".to_sym] : bb[:main]
    end
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
    return unless bounding_box
    return if through
    pass1 = (objbox[0].first <= box_xy[0].last) && (objbox[0].last >= box_xy[0].first)
    pass2 = (objbox[1].first <= box_xy[1].last) && (objbox[1].last >= box_xy[1].first)
    return pass1 && pass2
  end
  #--------------------------------------------------------------------------
  # * Tile box Collision
  #  Returns true if tile is passable ( No box collision. )
  #--------------------------------------------------------------------------
  def tilepass?(x, y, nx, ny)
    return false unless $game_map.valid?(x, y)
    tb = $game_map.tileboxes[x][y]
    return true if !tb || @through
    if tb[0].is_a?(Array)
      pass = []
      tb.each do |b|
        pass << tilebox?(b, nx, ny)
      end
      return pass.count(false) == pass.size 
    else
      return tilebox?(tb, nx, ny) == false
    end
  end
  #--------------------------------------------------------------------------
  # * Returns true if boxes are inside each other.
  #--------------------------------------------------------------------------
  def tilebox?(tilebox, nx, ny)
    box = box_xy(nx, ny)
    insidex = (box[0].last >= tilebox[0].first) && (box[0].first <= tilebox[0].last)
    insidey = (box[1].last >= tilebox[1].first) && (box[1].first <= tilebox[1].last)
    return insidex && insidey
  end
  #--------------------------------------------------------------------------
  # * Get Move Speed (Account for Dash)
  #--------------------------------------------------------------------------
  def real_move_speed
    @move_speed + (dash? ? 1 : 0) + (diagonal? ? Quasi::Movement::DIAGSPEED : 0)
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #--------------------------------------------------------------------------
  alias :qm_gcb_moveto    :moveto
  def moveto(x, y)
    qm_gcb_moveto(x,y)
    @px = @npx = x * 32.0
    @py = @npy = y * 32.0
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position (Pixel based)
  #--------------------------------------------------------------------------
  def p_moveto(px, py)
    @px = px % ($game_map.width*32)
    @py = py % ($game_map.height*32)
    @x = @px / 32.0
    @y = @py / 32.0
    @real_x = @x
    @real_y = @y
    @prelock_direction = 0
    straighten
    update_bush_depth
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
  # * Diagonal
  #--------------------------------------------------------------------------
  def diagonal?
    return [1, 3, 7 ,9].include?(@direction) if @dir8sprites
    return @diagonal
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
    @x = @real_x.truncate if @x != @real_x.truncate
    @y = @real_y.truncate if @y != @real_y.truncate
    
    @velocity -= speed
    update_bush_depth unless moving?
  end
  #--------------------------------------------------------------------------
  # * Update While Jumping
  #--------------------------------------------------------------------------
  alias :qm_gcb_jump    :update_jump
  def update_jump
    qm_gcb_jump
    @px = @real_x * 32
    @py = @real_y * 32
  end
  #--------------------------------------------------------------------------
  # * Move Straight
  #     d:        Direction (2,4,6,8)
  #     turn_ok : Allows change of direction on the spot
  #--------------------------------------------------------------------------
  def move_straight(d, turn_ok = true)
    @move_succeed = passable?(@px, @py, d)
    orginal_speed = @move_speed
    smart_move(d) if @smartmove[:speed]
    if @move_succeed
      set_direction(d)
      @velocity = move_tiles
      @diagonal = false
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
    @velocity = 0 unless @move_succeed
    if !@move_succeed && @smartmove[:dir]
      dir = @dir4_diag[d]
      horz1 = dir[0][0]
      horz2 = dir[1][0]
      vert1 = dir[0][1]
      vert2 = dir[0][1]
      if diagonal_passable?(@px, @py, horz1, vert1)
        move_diagonal(horz1, vert1)
      elsif diagonal_passable?(@px, @py, horz2, vert2)
        move_diagonal(horz2, vert2)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Move Diagonally
  #     horz:  Horizontal (4 or 6)
  #     vert:  Vertical (2 or 8)
  #--------------------------------------------------------------------------
  def move_diagonal(horz, vert)
    @move_succeed = diagonal_passable?(@px, @py, horz, vert)
    orginal_speed = @move_speed
    smart_move([horz, vert], true) if @smartmove[:speed]
    if @move_succeed
      @velocity = move_tiles
      @diagonal = true
      @npx = $game_map.round_px_with_direction(@px, horz, move_tiles)
      @npy = $game_map.round_py_with_direction(@py, vert, move_tiles)
      @px = $game_map.px_with_direction(@npx, reverse_dir(horz), move_tiles)
      @py = $game_map.py_with_direction(@npy, reverse_dir(vert), move_tiles)
      increase_steps
    end
    @move_speed = orginal_speed
    @velocity = 0 unless @move_succeed
    if @dir8sprites
      set_direction(@dir8.key([horz, vert]))
      dir_set = true
    else
      set_direction(horz) if @direction == reverse_dir(horz)
      set_direction(vert) if @direction == reverse_dir(vert)
    end
    if !@move_succeed && @smartmove[:dir]
      if passable?(@px, @py, horz)
        move_straight(horz)
      elsif passable?(@px, @py, vert)
        move_straight(vert)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Smart move
  #--------------------------------------------------------------------------
  def smart_move(d, diag=false)
    return if @move_succeed && !self.is_a?(Game_Player)
    while !@move_succeed
      break if @move_speed < 1
      @move_speed -= 1
      if diag
        @move_succeed = diagonal_passable?(@px, @py, d[0], d[1])
      else
        @move_succeed = passable?(@px, @py, d)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Fixed Move (Straight)
  #   - Moves a fixed amount of distance
  #--------------------------------------------------------------------------
  def fixed_move(dist)
    d = @direction
    @move_succeed = passable?(@px, @py, d)
    if @move_succeed
      @velocity = dist
      @diagonal = false
      @npx = $game_map.round_px_with_direction(@px, d, dist)
      @npy = $game_map.round_py_with_direction(@py, d, dist)
      @px = $game_map.px_with_direction(@npx, reverse_dir(d), dist)
      @py = $game_map.py_with_direction(@npy, reverse_dir(d), dist)
      increase_steps
    end
    @velocity = 0 unless @move_succeed
  end
  #--------------------------------------------------------------------------
  # * Bounding box array
  #--------------------------------------------------------------------------
  def bounding_box
    return @boundingbox if @boundingbox
    @boundingbox = [32,32,0,0]
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
  # * Find facing edge
  #--------------------------------------------------------------------------
  def edge(x=@px, y=@py, dir=@direction)
    tl = vertices(x, y)[0]
    tr = vertices(x, y)[1]
    bl = vertices(x, y)[2]
    br = vertices(x, y)[3]
    edges = {2 => [bl, br], 4 => [tl, bl], 6 => [tr, br], 8 => [tl, tr]}
    return edges[dir]
  end
  #--------------------------------------------------------------------------
  # * Find facing edge in 32 grid terms
  #--------------------------------------------------------------------------
  def edge32(x=@px, y=@py, dir=@direction)
    edge = edge(x, y, dir)
    x1 = (edge[0][0] / 32.0).truncate
    x2 = (edge[1][0] / 32.0).truncate
    y1 = (edge[0][1] / 32.0).truncate
    y2 = (edge[1][1] / 32.0).truncate
    return [[x1,  y1], [x2, y2]]
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
  #--------------------------------------------------------------------------
  # * Force Move Route
  #--------------------------------------------------------------------------
  alias :qm_gc_force    :force_move_route
  def force_move_route(move_route)
    qm_gc_force(move_route)
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
  #--------------------------------------------------------------------------
  # * Move Toward Character
  #--------------------------------------------------------------------------
  def move_toward_character(character)   
    dist = p_distance_from(character)
    sx = dist[0]
    sy = dist[1]
    if sx != 0 && sy != 0 && Quasi::Movement::DIR8
      move_diagonal(sx > 0 ? 4 : 6, sy > 0 ? 8 : 2)
    elsif sx.abs > sy.abs
      move_straight(sx > 0 ? 4 : 6)
      move_straight(sy > 0 ? 8 : 2) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 8 : 2)
      move_straight(sx > 0 ? 4 : 6) if !@move_succeed && sx != 0
    end
  end
  #--------------------------------------------------------------------------
  # * Move Away from Character
  #--------------------------------------------------------------------------
  def move_away_from_character(character)
    dist = p_distance_from(character)
    sx = dist[0]
    sy = dist[1]
    if sx != 0 && sy != 0 && Quasi::Movement::DIR8
      move_diagonal(sx > 0 ? 6 : 4, sy > 0 ? 2 : 8)
    elsif sx.abs > sy.abs
      move_straight(sx > 0 ? 6 : 4)
      move_straight(sy > 0 ? 2 : 8) if !@move_succeed && sy != 0
    elsif sy != 0
      move_straight(sy > 0 ? 2 : 8)
      move_straight(sx > 0 ? 6 : 4) if !@move_succeed && sx != 0
    end
  end
  #--------------------------------------------------------------------------
  # * Turn Toward Character
  #--------------------------------------------------------------------------
  def turn_toward_character(character)
    sx = distance_px_from(character)
    sy = distance_py_from(character)
    if sx.abs > sy.abs
      set_direction(sx > 0 ? 4 : 6)
    elsif sy != 0
      set_direction(sy > 0 ? 8 : 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Turn Away from Character
  #--------------------------------------------------------------------------
  def turn_away_from_character(character)
    sx = distance_px_from(character)
    sy = distance_py_from(character)
    if sx.abs > sy.abs
      set_direction(sx > 0 ? 6 : 4)
    elsif sy != 0
      set_direction(sy > 0 ? 2 : 8)
    end
  end
  #--------------------------------------------------------------------------
  # * Calculate Distance in X Axis Direction
  #--------------------------------------------------------------------------
  def distance_px_from(obj)
    result = @px - obj.px
    width = $game_map.width * 32
    if $game_map.loop_horizontal? && result.abs > width / 2
      if result < 0
        result += width
      else
        result -= width
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Calculate Distance in Y Axis Direction
  #--------------------------------------------------------------------------
  def distance_py_from(obj)
    result = @py - obj.py
    height = $game_map.height * 32
    if $game_map.loop_vertical? && result.abs > height / 2
      if result < 0
        result += height
      else
        result -= height
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Calculate Distance in pixel from obj
  #--------------------------------------------------------------------------
  def p_distance_from(obj)
    bb = bounding_box
    if bb.is_a?(Hash)
      bb = bb["dir#{direction}".to_sym] ? bb["dir#{direction}".to_sym] : bb[:main]
    end
    x1 = @px - obj.px
    y1 = @py - obj.py
    x2 = y2 = 0
    if obj.diagonal?
      x2 = x1.abs > bb[0] ? p_adjust_wbox(x1, :x, bb) : 0
      y2 = y1.abs > bb[1] ? p_adjust_wbox(y1, :y, bb) : 0
    elsif obj.direction == 4 || obj.direction == 6
      x2 = x1.abs > bb[0] ? p_adjust_wbox(x1, :x, bb) : 0
      y2 = v_center[1] - obj.v_center[1]
    elsif obj.direction == 8 || obj.direction == 2
      y2 = y1.abs > bb[1] ? p_adjust_wbox(y1, :y, bb) : 0
      x2 = v_center[0] - obj.v_center[0]
    end
    if self.is_a?(Game_Follower)
      return [x1, y1] if $game_player.followers_gathering?
    end
    return [x2, y2]
  end
  #--------------------------------------------------------------------------
  # * Adjust distance with box
  # (Finds out if it should add/sub the width or height of the box to value)
  #--------------------------------------------------------------------------
  def p_adjust_wbox(value, axis, bb)
    if axis == :x
      if value < 0
        value += bb[0]
      else
        value -= bb[0]
      end
    elsif axis == :y
      if value < 0
        value += bb[1]
      else
        value -= bb[1]
      end
    end
    return value
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
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     event:  RPG::Event
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    refresh
    init_pos(@event.x, @event.y)
  end
  #--------------------------------------------------------------------------
  # * Initialize starting position
  #--------------------------------------------------------------------------
  def init_pos(x, y)
    ox = initial_offset[0]
    oy = initial_offset[1]
    x1 = (x * 32) + ox
    y1 = (y * 32) + oy
    p_moveto(x1, y1)
  end
  #--------------------------------------------------------------------------
  # * Initial offsets
  #--------------------------------------------------------------------------
  def initial_offset
    unless @offsets
      ox = grab_comment(/<ox=(.*)>/i, 0)
      oy = grab_comment(/<oy=(.*)>/i, 0)
      @offsets = [ox.to_i, oy.to_i]
    end
    return @offsets
  end
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
  # * Set Up Event Page Settings
  #--------------------------------------------------------------------------
  alias :qm_ge_setup    :setup_page_settings
  def setup_page_settings
    qm_ge_setup
    @boundingbox = nil
    sub_qmove
  end
  #--------------------------------------------------------------------------
  # * Move Type : Random
  #--------------------------------------------------------------------------
  def move_type_random
    amt = rand(6)
    steps = (rand(32))/@grid * amt
    case qrand(steps+1)
    when 0..1;      move_random
    when 2..steps;  move_forward
    when steps+1;   @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Bounding box
  #--------------------------------------------------------------------------
  def bounding_box
    return @boundingbox if @boundingbox
    default = Quasi::Movement::EVENTBOX
    bb = Quasi::regex(comments, /<bbox>(.*)<\/bbox>/im, :linehash)
    if bb
      bb[:main] = default if !bb[:main]
    else
      default = "#{default[0]},#{default[1]},#{default[2]},#{default[3]}"
      bb = grab_comment(/<bbox=(.*)>/i, default)
      bb = bb.to_ary
    end
    @boundingbox = bb
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
  # * Tile box Collision
  #  Returns true if tile is passable ( No box collision. )
  #--------------------------------------------------------------------------
  def tilepass?(x, y, nx, ny)
    return false unless $game_map.valid?(x, y)
    tb = $game_map.tileboxes[x][y]
    if @vehicle_type == :boat || @vehicle_type == :ship
      return false unless tb
    end
    return true if !tb || @through
    if tb[0].is_a?(Array)
      pass = []
      tb.each do |b|
        pass << tilebox?(b, nx, ny)
      end
      if @vehicle_type == :boat 
        return tb[0][2] == 2063
      elsif @vehicle_type == :ship
        return tb[0][2] == 2063 || tb[0][2] == 2575
      end
      return pass.count(false) == pass.size 
    else
      if @vehicle_type == :boat 
        return tb[2] == 2063
      elsif @vehicle_type == :ship
        return tb[2] == 2063 || tb[2] == 2575
      end
      return tilebox?(tb, nx, ny) == false
    end
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Vehicle
  #--------------------------------------------------------------------------
  def collide_with_vehicles?(x, y)
    return false unless @vehicle_type == :walk
    $game_map.boat.box?(box_xy(x,y)) ||
    $game_map.ship.box?(box_xy(x,y))
  end
  #--------------------------------------------------------------------------
  # * Processing of Movement via Input from Directional Buttons
  #--------------------------------------------------------------------------
  def move_by_input
    return if !movable? || $game_map.interpreter.running?
    if Quasi::Movement::DIR8
      if Input.dir8 > 0
        dia = {7 => [4, 8], 1 => [4, 2], 9 => [6, 8], 3 => [6, 2]}
        if [1, 7, 9, 3].include?(Input.dir8)
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
    x2 = $game_map.unround_px(x)
    y2 = $game_map.unround_py(y)
    looped = $game_map.loop_horizontal? || $game_map.loop_vertical?
    boxes = $game_map.bounding_xy(box_xy(x, y), false)
    if looped && (x2 != x || y2 != y)
      boxes += $game_map.bounding_xy(box_xy(x2, y2), false) 
    end
    boxes.each do |event|
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
    start_map_event(x1, y1, triggers, true)
    return if $game_map.any_event_starting?
    edge = edge32(x1, y1, d)
    x2 = edge[0][0];    x3 = edge[1][0]
    y2 = edge[0][1];    y3 = edge[1][1]
    return unless $game_map.tilecounter?(x2, y2) || $game_map.tilecounter?(x3, y3)
    x4 = d == 4 ? x1-32 : d == 6 ? x1+32 : x1
    y4 = d == 8 ? y1-32 : d == 2 ? y1+32 : y1
    start_map_event(x4, y4, triggers, true)
  end
  #--------------------------------------------------------------------------
  # * Board Vehicle
  #    Assumes that the player is not currently in a vehicle.
  #--------------------------------------------------------------------------
  def get_on_vehicle
    front_x = $game_map.round_px_with_direction(@px, @direction, move_tiles)
    front_y = $game_map.round_py_with_direction(@py, @direction, move_tiles)
    @vehicle_type = :airship if $game_map.airship.box?(box_xy)
    @vehicle_type = :boat    if $game_map.boat.box?(box_xy(front_x, front_y))
    @vehicle_type = :ship    if $game_map.ship.box?(box_xy(front_x, front_y))
    if vehicle
      @vehicle_getting_on = true
      distx = vehicle.px - @px
      disty = vehicle.py - @py
      dist = disty
      dist = distx if @direction == 4 || @direction == 6
      if dist == distx
        dir = @direction
        newdir = disty < 0 ? 8 : 2
        set_direction(newdir)
        force_move_towards(disty.abs)
      elsif dist == disty
        dir = @direction
        newdir = distx < 0 ? 4 : 6
        set_direction(newdir)
        force_move_towards(distx.abs)
      end
      update_move while moving?
      set_direction(dir)
      force_move_towards(dist)
      @followers.gather
    end
    @vehicle_getting_on
  end
  #--------------------------------------------------------------------------
  # * Get Off Vehicle
  #    Assumes that the player is currently riding in a vehicle.
  #--------------------------------------------------------------------------
  def get_off_vehicle
    if vehicle.land_ok?(@px, @py, @direction)
      set_direction(2) if in_airship?
      @followers.synchronize(@x, @y, @direction)
      vehicle.get_off
      unless in_airship?
        force_move_towards(32)
        @transparent = false
      end
      @vehicle_getting_off = true
      @move_speed = 4
      @through = false
      make_encounter_count
      @followers.gather
    end
    @vehicle_getting_off
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
  # * Force One Step Forward
  #--------------------------------------------------------------------------
  def force_move_towards(dist)
    @through = true
    fixed_move(dist)
    @through = false
  end
  #--------------------------------------------------------------------------
  # * Check if followers are gathering
  #--------------------------------------------------------------------------
  def followers_gathering?
    return @followers.gathering?
  end
  #--------------------------------------------------------------------------
  # * Bounding box
  #--------------------------------------------------------------------------
  def bounding_box
    if vehicle
      return Quasi::Movement::VEHICLES[@vehicle_type]
    end
    return @boundingbox if @boundingbox
    @boundingbox = actor.actor.bounding_box
  end
end

#==============================================================================
# ** Game_Follower
#------------------------------------------------------------------------------
#  This class handles followers. A follower is an allied character, other than
# the front character, displayed in the party. It is referenced within the
# Game_Followers class.
#==============================================================================

class Game_Follower < Game_Character
  #--------------------------------------------------------------------------
  # * Pursue Preceding Character
  #--------------------------------------------------------------------------
  def chase_preceding_character
    unless moving?
      dist = p_distance_from(@preceding_character)
      sx = dist[0]
      sy = dist[1]
      if sx.abs > 2 && sy.abs > 2
        move_diagonal(sx > 0 ? 4 : 6, sy > 0 ? 8 : 2)
      elsif sx.abs > 2
        move_straight(sx > 0 ? 4 : 6)
      elsif sy.abs > 2
        move_straight(sy > 0 ? 8 : 2)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if at Same Position as Preceding Character
  #--------------------------------------------------------------------------
  def gather?
    !moving? && box?(@preceding_character.box_xy, false)
  end
  #--------------------------------------------------------------------------
  # * Bounding box
  #--------------------------------------------------------------------------
  def bounding_box
    return @boundingbox if @boundingbox
    if actor
      @boundingbox = actor.actor.bounding_box
    else
      @boundingbox = Quasi::Movement::PLAYERBOX
    end
  end
end

#==============================================================================
# ** Game_Vehicle
#------------------------------------------------------------------------------
#  This class handles vehicles. It's used within the Game_Map class. If there
# are no vehicles on the current map, the coordinates are set to (-1,-1).
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # * Synchronize With Player 
  #--------------------------------------------------------------------------
  alias :qm_gv_sync  :sync_with_player
  def sync_with_player
    qm_gv_sync
    @py = $game_player.py
    @px = $game_player.px
  end
  #--------------------------------------------------------------------------
  # * Determine if Docking/Landing Is Possible
  #     d:  Direction (2,4,6,8)
  #--------------------------------------------------------------------------
  def land_ok?(x, y, d)
    if @type == :airship
      return false unless tilebox_passable?(x, y, reverse_dir(d))
      return false unless tilebox_passable?(x, y, d)
      return false if collide_with_box?(x, y)
    else
      x1 = d == 4 ? x - 32 : d == 6 ? x + 32: x
      y1 = d == 8 ? y - 32 : d == 2 ? y + 32 : y
      x2 = $game_map.round_px(x1)
      y2 = $game_map.round_py(y1)
      x3 = $game_map.round_x((x1/32.0).round)
      y3 = $game_map.round_y((y1/32.0).round)
      return false unless $game_map.valid?(x3, y3)
      return false unless tilebox_passable?(x2, y2, d)
      return false if collide_with_box?(x2, y2)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Check for Bounding box Collision
  #  Returns true if boxes are inside each other.
  #--------------------------------------------------------------------------
  def box?(objbox, through=nil)
    return false if transparent
    super
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Character 
  #--------------------------------------------------------------------------
  def collide_with_box?(x, y)
    boxes = $game_map.bounding_xy(box_xy(x,y))
    unless boxes.empty?
      boxes.keep_if {|e| e != self && e.normal_priority?}
    end
    !boxes.empty?
  end
  #--------------------------------------------------------------------------
  # * Bounding box
  #--------------------------------------------------------------------------
  def bounding_box
    return @boundingbox if @boundingbox
    boxes = Quasi::Movement::VEHICLES
    @boundingbox = boxes[@type]
  end
end

#==============================================================================
# ** RPG::BaseItem
#==============================================================================

class RPG::Actor
  def bounding_box
    if @bounding_box.nil?
      default = Quasi::Movement::PLAYERBOX
      bb = Quasi::regex(@note, /<bbox>(.*)<\/bbox>/im, :linehash)
      if bb
        bb[:main] = default unless bb[:main]
      else
        bb = Quasi::regex(@note, /<bbox=(.*)>/i, :array, default)
      end
      @bounding_box = bb
    end
    return @bounding_box
  end
end

#==============================================================================
# FOLLOWING IS FOR SHOWING BOUNDING BOXES
# * These are onle required to show bounding boxes
#   There aren't required for the actual script and can be removed
#==============================================================================

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes an instance of the
# Game_Character class and automatically changes sprite state.
#==============================================================================

class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     character : Game_Character
  #--------------------------------------------------------------------------
  alias :qbox_init    :initialize
  def initialize(viewport, character = nil)
    qbox_init(viewport, character)
    start_box if Quasi::Movement::SHOWBOXES && $TEST
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias :qbox_update   :update
  def update
    qbox_update
    update_box if @box_sprite
  end
  #--------------------------------------------------------------------------
  # * Free
  #--------------------------------------------------------------------------
  alias :qbox_dispose   :dispose
  def dispose
    if @box_sprite
      @box_sprite.bitmap.dispose if @box_sprite.bitmap
      @box_sprite.dispose
    end
    qbox_dispose
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
    @bbox = @character.bounding_box
    @bdir = @character.direction
    if @bbox.is_a?(Hash)
      bb = @bbox["dir#{@bdir}".to_sym] ? @bbox["dir#{@bdir}".to_sym] : @bbox[:main]
    else
      bb = @bbox
    end
    bbox = bb[2].nil? ? 0 : bb[2]
    bboy = bb[3].nil? ? 0 : bb[3]
    @box_sprite.bitmap = Bitmap.new(bb[0], bb[1])
    @box_sprite.bitmap.fill_rect(@box_sprite.bitmap.rect, Quasi::Movement::BOXCOLOR)
    @box_sprite.ox += 16 - bbox
    @box_sprite.oy += 32 - bboy
    @box_sprite.x = @character.x
    @box_sprite.y = @character.y
    @box_sprite.z = z
    @box_sprite.blend_type = Quasi::Movement::BOXBLEND
  end
  #--------------------------------------------------------------------------
  # * Update Box
  #--------------------------------------------------------------------------
  def update_box
    return unless @box_sprite
    @box_sprite.x = x if @box_sprite.x != x 
    @box_sprite.y = y if @box_sprite.y != y
    @box_sprite.visible = self.visible
    if @bbox != @character.bounding_box
      start_box
    end
    if @character.bounding_box.is_a?(Hash)
      if @bdir != @character.direction
        start_box
      end
    end
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc. It's used
# within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias :qbox_sm_init    :initialize
  def initialize
    qbox_sm_init
    create_boxes if Quasi::Movement::SHOWBOXES && $TEST
  end
  #--------------------------------------------------------------------------
  # * Start Box Display
  #--------------------------------------------------------------------------
  def create_boxes
    return unless $game_map
    @box_sprite = Sprite.new
    @box_sprite.bitmap = Bitmap.new(32*$game_map.width, 32*$game_map.height)
    @box_sprite.blend_type = Quasi::Movement::BOXBLEND
    for x in 0..$game_map.width
      for y in 0..$game_map.height
        next unless $game_map.tileboxes[x]
        box = $game_map.tileboxes[x][y]
        next unless box
        if box[0].is_a?(Array)
          box.each {|b| makebox(b)}
        else
          makebox(box)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Adds box to bitmap
  #--------------------------------------------------------------------------
  def makebox(box)
    bw = box[0].last - box[0].first
    bh = box[1].last - box[1].first
    x = box[0].first
    y = box[1].first
    rect = Rect.new(x, y, bw, bh) 
    @box_sprite.bitmap.fill_rect(rect, Quasi::Movement::BOXCOLOR)
  end
  #--------------------------------------------------------------------------
  # * Free Tilebox
  #--------------------------------------------------------------------------
  def dispose_tilebox
    @box_sprite.bitmap.dispose if @box_sprite.bitmap
    @box_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Refresh Characters
  #--------------------------------------------------------------------------
  alias :qbox_sm_refresh    :refresh_characters
  def refresh_characters
    qbox_sm_refresh
    dispose_tilebox
    create_boxes
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias qbox_sm_update update
  def update
    qbox_sm_update
    update_boxes
  end
  #--------------------------------------------------------------------------
  # * Update Boxes
  #--------------------------------------------------------------------------
  def update_boxes
    return unless @box_sprite
    @box_sprite.ox = $game_map.display_x * 32
    @box_sprite.oy = $game_map.display_y * 32
  end
end
else
  msgbox(sprintf("[Quasi Movement] Requires Quasi module."))
end
