#==============================================================================
# ** Quasi Optimize v 1.1
#  Requires Quasi Movement [version 1.1.5+]
#   http://quasixi.com/movement/
#  Requires Quasi Module [version 0.4.5]
#    http://quasixi.com/quasi-module/
#  If links are down, try my github
#    https://github.com/quasixi/RGSS3
#==============================================================================
#  Optimizes Quasi Movement for higher performance.  Like all other anti-lag
# event scripts, this only keeps events that are on/near the screen.  If they
# are offscreen their sprites are disposed.  By doing this the collision
# checks only check for events on screen, instead of all the events on the map.
#==============================================================================
# How to install:
#  - Place this below Quasi Movement (link is above)
#  - Place this below any Quasi Movement addons ( like Collision Map )
#  - Make sure the version of Quasi Movement is the required version.
#==============================================================================
module Quasi
  module Optimize
    #--------------------------------------------------------------------------
    # Gives the screen some padding to allow some offscreen events to be added
    # When set to 0, and if you're moving quick you will see the events sprites
    # being added, but if you instead the value the events sprite will be added
    # before they are on screen.
    #--------------------------------------------------------------------------
    SCREENOFFSET_X = 5
    SCREENOFFSET_Y = 5
    #--------------------------------------------------------------------------
    # Event Comment Tags:
    #  <offscreen>
    #    An event with this comment will be able to move even when it's offscreen
    #   *Note* Collisions only check events that are on screen so offscreen events
    #    might end up inside another event.
    #
    #  <nosprite>
    #    An event with this comment won't have it's sprite created, which should
    #   be used on like system events / parallel events that have no sprite.
    #   *Note* If you don't know if you need this don't use it, it might not
    #    even provide a noticable performance enhance.
    #--------------------------------------------------------------------------
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
$imported["Quasi"] = 0 if $imported["Quasi"].nil?
$imported["Quasi_Movement"] = 0 if $imported["Quasi_Movement"].nil?
$imported["Quasi_Optimize"] = 1.1

if $imported["Quasi_Movement"] >= 1.31 && $imported["Quasi"] >= 0.45
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
    @last_gridpos = [0, 0]
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
    return unless SceneManager.scene_is?(Scene_Map)
    oldevents = map_events
    @onscreenevents = @events.values.select{|event| event_onscreen?(event)}
    @onscreenevents.each{|e| SceneManager.scene.spriteset_add(e)}
    remove = oldevents - map_events
    unless remove.empty?
      remove.each{|e| SceneManager.scene.spriteset_remove(e.id)}
    end
  end
  #--------------------------------------------------------------------------
  # * Check if x, y pos is on screen
  #--------------------------------------------------------------------------
  def event_onscreen?(event)
    return true if event.offscreen?
    return false if event.spriteless?
    x = event.x
    y = event.y
    hx = Quasi::Optimize::SCREENOFFSET_X
    hy = Quasi::Optimize::SCREENOFFSET_Y
    screenx = (@display_x.floor - hx)..(@display_x.floor + screen_tile_x + hx)
    screeny = (@display_y.floor - hy)..(@display_y.floor + screen_tile_y + hy)
    passedx = x >= screenx.first && x <= screenx.last
    passedy = y >= screeny.first && y <= screeny.last
    return passedx && passedy
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
  #--------------------------------------------------------------------------
  # * Update screen event whenever screen moved 1 grid
  #--------------------------------------------------------------------------
  def update_screenevents
    return unless update_lastgridpos?
    setup_onscreenevents
  end
  #--------------------------------------------------------------------------
  # * Checks last grid position
  #--------------------------------------------------------------------------
  def update_lastgridpos?
    if @last_gridpos != [@display_x.floor, @display_y.floor]
      @last_gridpos = [@display_x.floor, @display_y.floor]
      return true
    end
    return false
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
    return offscreen? ? true : qopt_ge_near(dx, dy)
  end
  def offscreen?
    return grab_comment(/<offscreen>/i)
  end
  def spriteless?
    return grab_comment(/<nosprite>/i)
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Create Sprite Set
  #--------------------------------------------------------------------------
  alias :qopt_sm_create   :create_spriteset
  def create_spriteset
    qopt_sm_create
    $game_map.setup_onscreenevents
  end
  
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
    @event_sprites.each_value{|sprite| sprite.update}
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
    return unless @event_sprites[id]
    @event_sprites.delete(id)
  end
  #--------------------------------------------------------------------------
  # * Add Event Sprite
  #--------------------------------------------------------------------------
  def add_event(event)
    return if @event_sprites[event.id]
    @event_sprites[event.id] = Sprite_Character.new(@viewport1, event)
  end
end
else
  msgbox(sprintf("[Quasi Optimize] Requires Quasi movement."))
end
