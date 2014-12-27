#==============================================================================
# ** Quasi Skill Type Equip v 3.0
#  Require Module Quasi
#   http://quasixi.com/quasi-module/
#==============================================================================
#  Allows players to equip skill types, the skill types the player can choose
# are from the skill type he has unlocked.  The player can also equip skill
# types they don't know if they have a skill that is for that skill type.
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v 3.0 - 11/14/14
#       - Rewritten
#==============================================================================
# Instructions:
#  Very simple to use, mostly plug and play.
#
#  For compatibility with Quasi Skill Equip and/or Quasi Passive
# use Quasi Equip Patches:
#
#  http://quasixi.com/quasi-equip-series-patch/
#
#  That script should go below all 3 of those scripts.
#------------------------------------------------------------------------------
module Quasi
  module STypeEquip
    #--------------------------------------------------------------------------
    # Title to appear in the command window.
    #--------------------------------------------------------------------------
    NAME = "Stype Equip"
    #--------------------------------------------------------------------------
    # Give descriptions to your skill types
    # stype_id => "description",
    # ** Don't forget the comma unless it's the last one
    #--------------------------------------------------------------------------
    DESC = {
    1 => "Special skills are very weak",
    2 => "Magic Skills are overpowered"
    }
  end
end
#------------------------------------------------------------------------------
# * Skill Type Tag
#------------------------------------------------------------------------------
#    <stype_slots: #>
# Can be placed in actors note box, or weapons/armor.  Default is 0
#
# If an actor has 2 stype slots, and equips a weapon with 2 more slots.  You
# will be able to equip 4 skill types.  If you unequip the weapon, the last
# 2 skill types equipped, will be unequipped.
#==============================================================================#
# By Quasi (http://quasixi.com/) || (https://github.com/quasixi/RGSS3)
#  - 11/14/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
$imported = {} if $imported.nil?
$imported["Quasi_STypeEquip"] = 3.0
 
if $imported["Quasi"]
#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This base class handles battlers. It mainly contains methods for calculating
# parameters. It is used as a super class of the Game_Battler class.
#==============================================================================
 
class Game_BattlerBase
  alias qesinit initialize
  attr_accessor   :equipped_skill_types
  #--------------------------------------------------------------------------
  # * Object Initialization
  # * ALIAS
  #--------------------------------------------------------------------------
  def initialize
    qesinit
    @equipped_skill_types = []
  end
end
 
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It is used within the Game_Actors class
# ($game_actors) and is also referenced from the Game_Party class ($game_party).
#==============================================================================
 
class Game_Actor < Game_Battler
  alias qstype_change change_equip
  #--------------------------------------------------------------------------
  # * NEW SType Slots
  #--------------------------------------------------------------------------
  def stype_slots
    slots = actor.stype_slots
    @equips.each {|eqp| next if eqp.object.nil? ; slots += eqp.object.stype_slots}
    return slots
  end
  #--------------------------------------------------------------------------
  # * NEW Check SType Slots
  #--------------------------------------------------------------------------
  def check_stype_slots
    if equipped_skill_types.size > stype_slots
      equipped_skill_types.slice!(stype_slots..equipped_skill_types.size)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Equipment
  #     slot_id:  Equipment slot ID
  #     item:    Weapon/armor (remove equipment if nil)
  # ** ALIAS **
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    qstype_change(slot_id, item)
    check_stype_slots
  end
end

#==============================================================================
# ** Scene_Skill
#------------------------------------------------------------------------------
#  This class performs skill screen processing. Skills are handled as items for
# the sake of process sharing.
#==============================================================================
 
class Scene_Skill < Scene_ItemBase
  alias qstype_ss_up update
  alias qstype_ss_ccw create_command_window
  alias qstype_ss_ciw create_item_window
  #--------------------------------------------------------------------------
  # * Update Method
  #--------------------------------------------------------------------------
  def update
    update_stype
    qstype_ss_up
  end
  #--------------------------------------------------------------------------
  # * NEW Update SType
  #--------------------------------------------------------------------------
  def update_stype
    case @command_window.command_name(@command_window.index)
    when Quasi::STypeEquip::NAME
      @stype_window.show if !@stype_window.visible
      @item_window.hide if @item_window.visible
    else
      @item_window.show if !@item_window.visible
      @stype_window.hide if @stype_window.visible
    end
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  # * ALIAS
  #--------------------------------------------------------------------------
  def create_command_window
    qstype_ss_ccw
    @command_window.set_handler(:stype,   method(:command_stype))
  end
  #--------------------------------------------------------------------------
  # * Create Skill type Window
  # * ALIAS
  #--------------------------------------------------------------------------
  def create_item_window
    qstype_ss_ciw
    wx = @item_window.x
    wy = @item_window.y
    ww = @item_window.width
    wh = @item_window.height
    @stype_window = Window_STypeList.new(wx, wy, ww, wh)
    @stype_window.actor = @actor
    @stype_window.viewport = @viewport
    @stype_window.help_window = @help_window
    @stype_window.set_handler(:ok,     method(:on_stype_ok))
    @stype_window.set_handler(:cancel, method(:on_stype_cancel))
  end
  #--------------------------------------------------------------------------
  # * NEW Skill Type Command
  #--------------------------------------------------------------------------
  def command_stype
    @actor.stype_slots
    @stype_window.activate
    @stype_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * NEW Skill Type [OK]
  #--------------------------------------------------------------------------
  def on_stype_ok
    if @stype_window.item
      if @actor.equipped_skill_types.include?(@stype_window.item)
        Sound.play_ok
        @actor.equipped_skill_types.delete(@stype_window.item)
      else
        if @actor.equipped_skill_types.size >= @actor.stype_slots
          Sound.play_buzzer
        else
          Sound.play_ok
          @actor.equipped_skill_types.push(@stype_window.item)
        end
      end
    end
    @stype_window.refresh
    @stype_window.activate
    @command_window.refresh
  end
  #--------------------------------------------------------------------------
  # * NEW Skill Type [Cancel]
  #--------------------------------------------------------------------------
  def on_stype_cancel
    @stype_window.unselect
    @command_window.activate
  end
end
 
#==============================================================================
# ** Window_SkillCommand
#------------------------------------------------------------------------------
#  This window is for selecting commands (special attacks, magic, etc.) on the
# skill screen.
#==============================================================================

class Window_SkillCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Create Command List
  # * OVERWRITE
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Quasi::STypeEquip::NAME, :stype, true)
    return unless @actor
    @actor.equipped_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
end
 
#==============================================================================
# ** Window_STypeList (NEW)
#------------------------------------------------------------------------------
#  This window is for displaying a list of available skills types
#  on the skill window.
#==============================================================================
 
class Window_STypeList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @actor = nil
    @data = []
  end
  #--------------------------------------------------------------------------
  # * Set Actor
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    self.oy = 0
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 2
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # * Get Skill
  #--------------------------------------------------------------------------
  def item
    @data && index >= 0 ? @data[index] : nil
  end
  #--------------------------------------------------------------------------
  # * Processing When OK Button Is Pressed
  #--------------------------------------------------------------------------
  def process_ok
    Input.update
    deactivate
    call_ok_handler
  end
  #--------------------------------------------------------------------------
  # * Create Skill List
  #--------------------------------------------------------------------------
  def make_item_list
    return if !@actor
    @data += @actor.added_skill_types
    @actor.skills.each do |s|
      @data.push(s.stype_id)
    end
    if $imported["Quasi_Passive"]
      @data.delete(Quasi::Passive::TYPE)
    end
    @data.uniq!; @data.sort!
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill
      stype = $data_system.skill_types[skill]
      rect = item_rect(index)
      rect.width -= 4
      enable = @actor.equipped_skill_types.include?(skill)
      change_color(normal_color, enable)
      draw_text(rect.x + 24, rect.y, 172, 24, stype)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    stype = Quasi::STypeEquip::DESC[@data[index]]
    stype = "" if stype.nil?
    sa = @actor.skills.select {|s| s.stype_id==@data[index]}
    sa = sa.size
    stype += "\n #{sa} Skills known."
    @help_window.set_text(stype)
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
end
 
#==============================================================================
# ** Window_ActorCommand
#------------------------------------------------------------------------------
#  This window is for selecting an actor's action on the battle screen.
#==============================================================================
 
class Window_ActorCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Add Skill Command to List
  # * OVERWRITE
  #--------------------------------------------------------------------------
  def add_skill_commands
    @actor.equipped_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
end
 
#==============================================================================
# ** RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  def stype_slots
    if @stype_slots.nil?
      @stype_slots = Quasi::regex(@note, /<stype_slots:(.*)>/i, :int, 0)
    end
    return @stype_slots
  end
end

else
  msgbox(sprintf("[Quasi Skill Type Equip] Requires Quasi module."))
end
