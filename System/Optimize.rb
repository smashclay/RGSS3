#==============================================================================
# ** Quasi Optimize v 0.8
#  Requires Quasi Movement [version 1.1.5+]
#   http://quasixi.com/movement/
#==============================================================================
#  Optimizes Quasi Movement for higher performance.  Like all other anti-lag
# event scripts, this only keeps events that are on/near the screen.  If they
# are offscreen their sprites are disposed.  By doing this the collision
# checks only check for events on screen, instead of all the events on the map.
#
#  Want to use someone elses anti-lag script?  No problem!
#  On line 62 you will see def map_events
#  change the return value in that def to to event list / list method that
#  the anti lag uses.  Default VXA uses @events.values
#==============================================================================
# How to install:
#  - Place this below Quasi Movement (link is above)
#  - Make sure the version of Quasi Movement is the required version.
#==============================================================================
module Quasi
  module Optimize
    #--------------------------------------------------------------------------
    # Set to true if you want events that are offscreen to still be able
    # to move.  This will actually drop performance, vx ace has this set on
    # false by default.
    #--------------------------------------------------------------------------
    EVENTMOVE = false
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
$imported["Quasi_Optimize"] = 0.8

if $imported["Quasi_Movement"]
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
  alias :qopt_gm_setup    :setup
  def setup(map_id)
    qopt_gm_setup(map_id)
    @onscreenevents = []
  end
  #--------------------------------------------------------------------------
  # * Get all events on screen
  #--------------------------------------------------------------------------
  def map_events
    return @onscreenevents
  end
  #--------------------------------------------------------------------------
  # * Set Display Position
  #--------------------------------------------------------------------------
  alias :qopt_gm_set_display    :set_display_pos
  def set_display_pos(x, y)
    qopt_gm_set_display(x, y)
    setup_onscreenevents
  end
  #--------------------------------------------------------------------------
  # * Setup on screen events
  #--------------------------------------------------------------------------
  def setup_onscreenevents
    hx = 2
    hy = 2
    screenx = (@display_x.truncate-hx)..(@display_x.truncate+screen_tile_x+hx)
    screeny = (@display_y.truncate-hy)..(@display_y.truncate+screen_tile_y+hy)
    oldevents = map_events
    for x in screenx
      for y in screeny
        e = @events.values.select{|event| event.pos?(x, y)}
        unless e.empty?
          e.each do |e2|
            next if @onscreenevents.include?(e2)
            @onscreenevents << e2
            SceneManager.scene.spriteset_add(e2) if SceneManager.scene_is?(Scene_Map)
          end
        end
      end
    end
    remove = oldevents - map_events
    unless remove.empty?
      if SceneManager.scene_is?(Scene_Map)
        remove.each{|e| SceneManager.scene.spriteset_remove(e.id)}
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #     main:  Interpreter update flag
  #--------------------------------------------------------------------------
  alias :qopt_gm_ups    :update
  def update(main = false)
    qopt_gm_ups(main)
    update_screenevents
  end
  
  def update_screenevents
    return unless $game_player.update_lastgridpos?
    setup_onscreenevents
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
  # * Initialize Quasi Movement setting variables
  #--------------------------------------------------------------------------
  alias :qopt_gcb_init    :init_quasi_variables
  def init_quasi_variables
    qopt_gcb_init
    @lasttile = []
    @lastbox  = []
  end
  #--------------------------------------------------------------------------
  # * Determine if Tile is Passable
  #--------------------------------------------------------------------------
  alias :qopt_gcb_tilebox   :tilebox_passable?
  def tilebox_passable?(x, y, d)
    unless qopt_gcb_tilebox(x, y, d)
      p "failed" if self.is_a?(Game_Player)
      @lasttile << [x, y, d] 
      @lasttile.shift if @lasttile.length > 2
    end
    return true unless @lasttile.include?([x, y, d])
    return false
  end
  #--------------------------------------------------------------------------
  # * Detect Collision with Character 
  #--------------------------------------------------------------------------
  alias :qopt_gcb_box   :collide_with_box?
  def collide_with_box?(x, y)
    if qopt_gcb_box(x, y)
      @lastbox << [x, y] 
      @lastbox.shift if @lastbox.length > 2
    end
    return true if @lastbox.include?([x, y])
    return false
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
  # * Initialize Public Member Variables
  #--------------------------------------------------------------------------
  alias :qopt_gc_init   :init_private_members
  def init_private_members
    qopt_gc_init
    @last_gridpos = [0, 0]
  end
  #--------------------------------------------------------------------------
  # * Checks last grid position
  #--------------------------------------------------------------------------
  def update_lastgridpos?
    if @last_gridpos != [@x, @y]
      @last_gridpos = [@x, @y]
      return true
    end
    return false
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
  # * Determine if Near Visible Area of Screen
  #     dx:  A certain number of tiles left/right of screen's center
  #     dy:  A certain number of tiles above/below screen's center
  #--------------------------------------------------------------------------
  alias :qopt_ge_near    :near_the_screen?
  def near_the_screen?(dx = 12, dy = 8)
    if Quasi::Optimize::EVENTMOVE
      return true
    else
      qopt_ge_near(dx, dy)
    end
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  def spriteset_add(event)
    @spriteset.add_event(event)
  end
  
  def spriteset_remove(id)
    @spriteset.remove_event(id)
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
  # * Create Character Sprite
  # * OVERWRITE
  #--------------------------------------------------------------------------
  def create_characters
    @character_sprites = []
    @event_sprites = {}
    @screenevents = $game_map.map_events
    @screenevents.each do |event|
      add_event(event)
    end
    $game_map.vehicles.each do |vehicle|
      @character_sprites.push(Sprite_Character.new(@viewport1, vehicle))
    end
    $game_player.followers.reverse_each do |follower|
      @character_sprites.push(Sprite_Character.new(@viewport1, follower))
    end
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    @map_id = $game_map.map_id
  end
  #--------------------------------------------------------------------------
  # * Update Character Sprite
  #--------------------------------------------------------------------------
  alias :qopt_sm_upc    :update_characters
  def update_characters
    qopt_sm_upc
    @event_sprites.each_value{|sprite| sprite.update }
  end
  #--------------------------------------------------------------------------
  # * Free Character Sprite
  #--------------------------------------------------------------------------
  alias :qopt_sm_disc   :dispose_characters
  def dispose_characters
    qopt_sm_disc
    @event_sprites.each_value{|sprite| sprite.dispose }
  end
  #--------------------------------------------------------------------------
  # * Free Event Sprite
  #--------------------------------------------------------------------------
  def remove_event(id)
    @event_sprites[id].dispose
  end
  #--------------------------------------------------------------------------
  # * Add Event Sprite
  #--------------------------------------------------------------------------
  def add_event(event)
    @event_sprites[event.id] = Sprite_Character.new(@viewport1, event)
  end
end
else
  msgbox(sprintf("[Quasi Optimize] Requires Quasi movement."))
end
