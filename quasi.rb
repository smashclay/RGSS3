#==============================================================================
# ** Quasi v0.3
#==============================================================================
#  Adds new methods to VXA's default classes and modules which is found to
# be useful.
#
# These methods will be used in other scripts create by Quasi, so instead of
# making them over and over, they will be placed here.
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v0.3 - Added a couple of new methods, and removed some from game_party
# --
# v0.2 - Changed followers to be made when there are party members instead of
#        already being made.
#      - Fix to angle, had a typo.
# --
# v0.1 - Pre-Released for movement script
#==============================================================================
module Quasi
  #--------------------------------------------------------------------------
  # * Master volume control.  VXA default sounds are too loud on my pc
  #   so I have it set at -70 when testing scripts.
  #--------------------------------------------------------------------------
  VOLUME = 0
  #--------------------------------------------------------------------------
  # * Allows for a quick test by skipping the title screen starting a 
  # new game.  Only works when play testing.
  #--------------------------------------------------------------------------
  QUICKTEST = false
  #--------------------------------------------------------------------------
  # * Set to true to use quasis follower mod, or false to ignore quasis 
  # follower mod.  With quasis mod, followers are only created when they
  # are present.  By default followers are created even when there's 1 character.
  # *NOTE* Might be buggy, but its nice for games that do not use followers
  #--------------------------------------------------------------------------
  FOLLOWERS = false
#==============================================================================
# ** New Features / Addons
#==============================================================================
#------------------------------------------------------------------------------
# * State add fixed Parameter value
#------------------------------------------------------------------------------
#  States can now add fixed values to parameters, instead of by a percent
# from the features list!
#  To use: 
#   Inside the state database you create a note tag
#     <param change>
#     param => value
#     </param change>
#   Whereparam can be: MHP, MMP, ATK, DEF, MAT, MDF, AGI, LUK
#
#  Example:
#     <param change>
#     MHP => 100
#     ATK => 20
#     </param change>
#   Would result in that state adding 100 to max hp and 20 to attack.
#  * value can be negative
#  * param is not case sensative
#
#------------------------------------------------------------------------------
# * Animation zoom range
#------------------------------------------------------------------------------
#  Allows for animations to display at different sizes each time they are played.
#   To use:
#    In animation's name include a range inside <>'s
#    
#    Example:
#      02:Hit Fire <-50..50>
#    Animation will play at a random size between -50% to 50%
#
#------------------------------------------------------------------------------
# * New method list ( For other scripters and myself)
#------------------------------------------------------------------------------
#  module SceneManager
#    def self.run
#      * Rewriten for a QUICKTEST, uses orginal method if QUICKTEST is false
#
#  class Game_BattlerBase
#    def param(param_id)
#      * Added extra values from state param_change
#
#    def state_param_plus(param_id)
#      * Grabs the extra parameter values
#
#  class Game_Party
#    def add_actor & def remove_actor
#      * Recreates followers
#
#    def avg_level & def avg_param(param_id)
#      * Exactly what it sounds like
#
#  class Game_Map
#    def clone_event(x, y, mapid, eventid)
#      * Copies event from the mapid to the current map at x,y
#
#  class Game_Follower & Game_Followers
#   def initialize
#      * Doesn't make all the followers at start anymore.
#
#   def recreate
#      * Used to create followers when they are added to party.
#
#  class Game_Event
#    def grab_comment(regex, default)
#      * This def grabs comments from the event, if no default is set
#      it will return true or false if the regex was found.
#
#  class Game_Interpeter
#    def any_switch?(switches, value)
#      * checks if any switch given in the param is equal to the set value.  
#
#    def all_switch?(switches, value)
#      * checks if all switches are equal to the given value.
#
#    **For def any_switch? and def all_switches?
#      * parameter switches must be a range or an array.
#        - Range Ex1: (1..5) results numbers 1 through 5
#          Range Ex2: (1...5) excludes last number, results numbers 1 through 4
#          Array Ex1:  [1, 2, 3, 4, 5] results in numbers 1 through 5
#          Array Ex2:  [1, 3, 5, 7, 9] results in numbers 1, 3, 5, 7, 9
#
#  class Sprite_Base
#    alias start_animation
#    alias animation_set_sprites
#      * New feature that allows animations to appear different sizes each time.
#
#  class Scene_Base
#    def wait(duration)
#      * Waits duration time before continuing
#
#  class Scene_Map
#    def spriteset_refresh
#      * refreshes the spriteset characters
#
#  module Kernel
#    def qrand(max)
#      * Created my own rand.  A range can be used ex: qrand(-20..20)  
#        It stores previous 3 randoms and if the current random is equal 
#        to any of previous 3 it will run again.
#
#  module Math
#    def self.angle(point1, point2)
#      * Returns the angle of line made by point1 and point2
#
#    def self.circle(cx,cy,radius,angle)
#      * Gets the x,y position on a circle from the given values
#        cx and cy are center x/y
#        radius is the radius of the circle
#        angle is the angle you want the new points at.
#
#  class String
#    def to_range
#      * Converts string to a range.  Needs to be written as a range
#        "0..10" or "0...10"
#
#    def abc?
#      * Checks if the string only contains letters
#
#    def int?
#      * Checks if the string only contains numbers
#
#  class Array
#    def to_h
#      * Converts array to hash
#
#  RPG::State
#    def param_change
#      * Gets param_change note tag
#
#  RPG::Animation
#    def zoom_range
#      * Used to grab the random animation zoom range from the name.  If regex
#        is not found it defaults to 0 which means no change in size.
#
#  RPG::SE | RPG::BGM | RPG::ME | RPG::BGS
#    def play
#      * Added a master volume control.  Value set on line 94
#==============================================================================
#==============================================================================#
# By Quasi (http://quasixi.wordpress.com/)
#  - 11/11/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
  #--------------------------------------------------------------------------
  # * Simple regex grabber
  #  Used for my notetags
  #--------------------------------------------------------------------------
  def self.regex(string, regex, returnvalue=:na, default=false)
    if string =~ regex
      if $1
        case returnvalue
        when :string
          result = $1.to_s
        when :int
          result = $1.to_i
        when :array
          result = $1.split(",")
        when :intarray
          result = $1.split(",").map {|s| s.to_i}
        when :linearray
          result = []
          for line in $1.split("\r\n")
            result << line if line != ""
          end
        when :linehash
          result = {}
          for line in $1.split("\r\n")
            next if line == ""
            hash = line.split("=>")
            key = hash[0] ? hash[0].strip : nil
            value = hash[1] ? hash[1].strip : nil
            result[key] = value
          end
        else
          result = $1
        end
      else
        result = true
      end
    else
      result = default
    end
    return result
  end
end

$imported = {} if $imported.nil?
$imported["Quasi"] = 0.3

#==============================================================================
# ** SceneManager
#------------------------------------------------------------------------------
#  This module manages scene transitions. For example, it can handle
# hierarchical structures such as calling the item screen from the main menu
# or returning from the item screen to the main menu.
#==============================================================================

module SceneManager
  #--------------------------------------------------------------------------
  # * Alias self.run
  #--------------------------------------------------------------------------
  class << self
    alias qsm_run run
  end
  #--------------------------------------------------------------------------
  # * Execute
  #--------------------------------------------------------------------------
  def self.run
    if Quasi::QUICKTEST && $TEST
      DataManager.init
      Audio.setup_midi if use_midi?
      DataManager.setup_new_game
      $game_map.autoplay
      @scene = Scene_Map.new
      @scene.main while @scene
    else
      qsm_run
    end
  end
end

#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This base class handles battlers. It mainly contains methods for calculating
# parameters. It is used as a super class of the Game_Battler class.
#==============================================================================

class Game_BattlerBase
  alias qgbb_param param
  #--------------------------------------------------------------------------
  # * Get Parameter
  #--------------------------------------------------------------------------
  def param(param_id)
    value = qgbb_param(param_id)
    value += state_param_plus(param_id)
    [[value, param_max(param_id)].min, param_min(param_id)].max.to_i
  end
  
  def state_param_plus(param_id)
    value = 0
    states.each do |state|
      next unless state.param_change
      param_change = state.param_change[param_id]
      value += param_change.to_i if param_change
    end
    return value
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles parties. Information such as gold and items is included.
# Instances of this class are referenced by $game_party.
#==============================================================================
 
class Game_Party < Game_Unit
if Quasi::FOLLOWERS
  #--------------------------------------------------------------------------
  # * Add an Actor
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    if !@actors.include?(actor_id)
      @actors.push(actor_id)
      $game_player.followers.recreate
      SceneManager.scene.spriteset_refresh if SceneManager.scene_is?(Scene_Map)
    end
    $game_player.refresh
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # * Remove Actor
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    @actors.delete(actor_id)
    $game_player.followers.recreate
    SceneManager.scene.spriteset_refresh if SceneManager.scene_is?(Scene_Map)
    $game_player.refresh
    $game_map.need_refresh = true
  end
end
  #--------------------------------------------------------------------------
  # * Get Average Level of Party Members
  #--------------------------------------------------------------------------
  def avg_level
    avg = 0
    members.each {|actor| avg += actor.level}
    avg /= members.size
    return avg
  end
  #--------------------------------------------------------------------------
  # * Get Average Value of param of Party Members
  #--------------------------------------------------------------------------
  def avg_param(param_id)
    avg = 0
    members.each {|actor| avg += actor.param(param_id)}
    avg /= members.size
    return avg
  end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Clone event from any map to x,y pos
  #--------------------------------------------------------------------------
  def clone_event(x,y,mapid,eventid)
    cmap = load_data(sprintf("Data/Map%03d.rvdata2", mapid))
    return if cmap.events[eventid].nil?
    cmap.events[eventid].x = x
    cmap.events[eventid].y = y
    @events[@events.length+1] = Game_Event.new(mapid, cmap.events[eventid])
    SceneManager.scene.spriteset_refresh
    refresh
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
if Quasi::FOLLOWERS
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(member_index, preceding_character)
    super()
    @member_index = member_index
    @preceding_character = !preceding_character ? $game_player : preceding_character
    @transparent = $data_system.opt_transparent
    @through = true
  end
end
end

#==============================================================================
# ** Game_Followers
#------------------------------------------------------------------------------
#  This is a wrapper for a follower array. This class is used internally for
# the Game_Player class. 
#==============================================================================

class Game_Followers
if Quasi::FOLLOWERS
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     leader:  Lead character
  #--------------------------------------------------------------------------
  def initialize(leader)
    @visible = $data_system.opt_followers
    @gathering = false                    # Gathering processing underway flag
    @data = []
    $data_system.party_members.each_index do |index|
      next if index == 0
      prec = index == 1 ? leader : @data[-1]
      @data.push(Game_Follower.new(index, prec))
    end
  end
  #--------------------------------------------------------------------------
  # * Recreate
  #--------------------------------------------------------------------------
  def recreate
    @data = []
    $game_party.battle_members.each_index do |index|
      next if index == 0
      prec = index == 1 ? $game_player : @data[-1]
      @data.push(Game_Follower.new(index, prec))
    end
    synchronize($game_player.x, $game_player.y, $game_player.direction)
  end
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
  # * Grabs comment from event
  #--------------------------------------------------------------------------
  def grab_comment(regex,default=nil)
    return unless @list
    reg = []
    @list.each do |cmd|
      next if cmd.code != 108
      comment = cmd.parameters[0]
      next unless comment =~ regex
      if !default.nil?
        reg << $1
      else
        reg = [true]
      end
    end
    return default if reg.empty?
    return reg if reg.length > 1
    return reg[0]
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
  # * Checks if any switch is equal to the value
  #--------------------------------------------------------------------------
  def any_switch?(switches, value=true)
    return switches.any?{|i| $game_switches[i] == value}
  end
  #--------------------------------------------------------------------------
  # * Checks if all switches are equal to the value
  #--------------------------------------------------------------------------
  def all_switch?(switches, value=true)
    return switches.all?{|i| game_switches[i] == value}
  end
end

#==============================================================================
# ** Sprite_Base
#------------------------------------------------------------------------------
#  A sprite class with animation display processing added.
#==============================================================================

class Sprite_Base < Sprite
  alias quasi_start_animation start_animation
  alias quasi_animation_set animation_set_sprites
  #--------------------------------------------------------------------------
  # * Start Animation
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    quasi_start_animation(animation, mirror)
    if @animation
      @rand = qrand(@animation.zoom_range)
    end
  end
  #--------------------------------------------------------------------------
  # * Set Animation Sprite
  #     frame : Frame data (RPG::Animation::Frame)
  #--------------------------------------------------------------------------
  def animation_set_sprites(frame)
    quasi_animation_set(frame)
    return if @rand == 0
    cell_data = frame.cell_data
    @ani_sprites.each_with_index do |sprite, i|
      next unless sprite
      pattern = cell_data[i, 0]
      next if !pattern || pattern < 0
      sprite.zoom_x += @rand/100.0
      sprite.zoom_y += @rand/100.0
    end
  end
end

#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  This is a super class of all scenes within the game.
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Wait
  #--------------------------------------------------------------------------
  def wait(duration)
    duration.times {|i| update_basic if i < duration }
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  This class performs the map screen processing.
#==============================================================================

class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # * Refresh spriteset
  #--------------------------------------------------------------------------
  def spriteset_refresh
    @spriteset.refresh_characters
  end
end 

#==============================================================================
# ** Kernel
#==============================================================================

module Kernel
  #--------------------------------------------------------------------------
  # * New random method that recordes the previous 3 randoms
  # if current random is equal to any of the previous 3, it runs again
  #--------------------------------------------------------------------------
  def qrand(max)
    max = 1 if max == 0
    @prevRand = [] if @prevRand.nil?
    value = Random.new.rand(max)
    value = Random.new.rand(max) if @prevRand.include?(value)
    @prevRand << value
    @prevRand.shift if @prevRand.length > 3
    return value
  end
end

#==============================================================================
# ** Math
#==============================================================================
module Math
  #--------------------------------------------------------------------------
  # * Calculate angle between 2 points
  #--------------------------------------------------------------------------
  def self.angle(point1,point2)
    x = point2[0] - point1[0]
    y = point2[1] - point1[1]
    radian = atan2(y, x)
    angle = (radian / PI) * 180
    return angle
  end
  #--------------------------------------------------------------------------
  # * Calculate pos on a circle
  #--------------------------------------------------------------------------
  def self.circle(cx, cy, radius, angle)
    x = cx + Math.sin(angle)*radius
    y = cy + Math.cos(angle)*radius
    return [x, y]
  end
end

#==============================================================================
# ** String
#==============================================================================
class String
  #--------------------------------------------------------------------------
  # * Converts the string to a range
  #--------------------------------------------------------------------------
  def to_range
    return unless self.include? ".."
    literal = (self.include?"...") ? literal = "..." : literal = ".."
    range = self.split(literal).map {|x| x.to_i}
    return range[0]..range[1] if literal == ".."
    return range[0]...range[1]
  end
  #--------------------------------------------------------------------------
  # * Checks if string only contains letters
  #--------------------------------------------------------------------------
  def abc?
    return self =~ /[A-Za-z]/
  end
  #--------------------------------------------------------------------------
  # * Checks if string only contains numbers
  #--------------------------------------------------------------------------
  def int?
    return self =~ /[0-9]/
  end
end

#==============================================================================
# ** Array
#==============================================================================
class Array
  def to_h
    return Hash[self]
  end
end

#==============================================================================
# ** RPG::State
#==============================================================================
class RPG::State
  def param_change
    if !@param_change
      regex = /<(?:param_change|param change)>(.*)<\/(?:param_change|param change)>/im
      temp = Quasi::regex(@note, regex, :linehash, false)
      id = {"mhp" => 0, "mmp" => 1, "atk" => 2, "def" => 3, "mat" => 4,
             "mdf" => 5, "agi" => 6, "luk" => 7}
      if temp
        @param_change = temp.map {|key, v| [id[key.downcase] || key, v]}.to_h
      else
        @param_change = false
      end
    end
    return @param_change
  end
end

#==============================================================================
# ** RPG::Animation
#==============================================================================

class RPG::Animation
  #--------------------------------------------------------------------------
  # * Zoom Range name tag
  #--------------------------------------------------------------------------
  def zoom_range
    if !@zoom_range
      @zoom_range = @name =~ /<(.*)>/i ? $1.to_range : 0
    end
    return @zoom_range
  end
end

#==============================================================================
# ** RPG::SE | RPG::BGM | RPG::ME | RPG::BGS
#==============================================================================

class RPG::SE < RPG::AudioFile
  def play
    unless @name.empty?
      volume = @volume + Quasi::VOLUME
      volume = 0 if volume < 0
      Audio.se_play('Audio/SE/' + @name, volume, @pitch)
    end
  end
end
class RPG::BGM < RPG::AudioFile
  def play(pos = 0)
    if @name.empty?
      Audio.bgm_stop
      @@last = RPG::BGM.new
    else
      volume = @volume + Quasi::VOLUME
      volume = 0 if volume < 0
      Audio.bgm_play('Audio/BGM/' + @name, volume, @pitch, pos)
      @@last = self.clone
    end
  end
end
class RPG::ME < RPG::AudioFile
  def play
    if @name.empty?
      Audio.me_stop
    else
      volume = @volume + Quasi::VOLUME
      volume = 0 if volume < 0
      Audio.me_play('Audio/ME/' + @name, volume, @pitch)
    end
  end
end
class RPG::BGS < RPG::AudioFile
  def play(pos = 0)
    if @name.empty?
      Audio.bgs_stop
      @@last = RPG::BGS.new
    else
      volume = @volume + Quasi::VOLUME
      volume = 0 if volume < 0
      Audio.bgs_play('Audio/BGS/' + @name, volume, @pitch, pos)
      @@last = self.clone
    end
  end
end
