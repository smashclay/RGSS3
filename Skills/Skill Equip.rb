#==============================================================================
# ** Quasi Skill Equip v 1.1
#  Require Module Quasi
#   http://code.quasixi.com/page/post/quasi+module/
#==============================================================================
# Allows players to equip skills
# - Player needs to know the skills to be able to equip them!
#   When skills are equipped, the skills skill types aren't!
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v 2.0 - 11/14/14
#       - Rewritten
#       - Fixed a bug with skills not unequipping if forgotten
#==============================================================================
# Instructions:
#  Very simple to use, mostly plug and play.
#
#  For compatibility with Quasi Passive and/or Quasi Skill Type Equip
# use Quasi Equip Patches:
#
#  http://code.quasixi.com/page/post/4/
#
#  That script should go below all 3 of those scripts.
#------------------------------------------------------------------------------
module Quasi
  module SkillEquip
    #--------------------------------------------------------------------------
    # The name of the command
    #--------------------------------------------------------------------------
    NAMESKILL   = "Skill Equip"
    #--------------------------------------------------------------------------
    # What to show in the help window.
    # shows "Skills Equiped: total/max"
    #--------------------------------------------------------------------------
    HELP        = "Skills Equiped"
  end
end
#------------------------------------------------------------------------------
# * Skill Slots Tag
#------------------------------------------------------------------------------
#    <skill_slots: #>
# Can be placed in actors note box, or weapons/armor.  Default is 0
#
# If an actor has 2 skill slots, and equips a weapon with 2 more slots.  You
# will be able to equip 4 skills.  If you unequip the weapon, the last
# 2 skills equipped, will be unequipped.
#==============================================================================#
# By Quasi (http://quasixi.com/) || (https://github.com/quasixi/RGSS3)
#  - 11/14/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
$imported = {} if $imported.nil?
$imported["Quasi_SkillEquip"] = 2.0
 
 
if $imported["Quasi"]
#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This base class handles battlers. It mainly contains methods for calculating
# parameters. It is used as a super class of the Game_Battler class.
#==============================================================================
 
class Game_BattlerBase
  alias qskill_init initialize
  attr_accessor   :equipped_skills
  #--------------------------------------------------------------------------
  # * Object Initialization
  # * ALIAS
  #--------------------------------------------------------------------------
  def initialize
    qskill_init
    @equipped_skills = []
  end
end
 
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It is used within the Game_Actors class
# ($game_actors) and is also referenced from the Game_Party class ($game_party).
#==============================================================================
 
class Game_Actor < Game_Battler
  alias qskill_change change_equip
  alias qskill_forget forget_skill
  #--------------------------------------------------------------------------
  # * Change Equipment
  #     slot_id:  Equipment slot ID
  #     item:    Weapon/armor (remove equipment if nil)
  # ** ALIAS **
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    qskill_change(slot_id, item)
    check_skill_slots
  end
  #--------------------------------------------------------------------------
  # *NEW Skill Slots
  #--------------------------------------------------------------------------
  def skill_slots
    sslots = actor.skill_slots
    @equips.each {|eqp| next if eqp.object.nil? ; sslots += eqp.object.skill_slots}
    sslots
  end
  #--------------------------------------------------------------------------
  # * New Check Skill Slots
  #--------------------------------------------------------------------------
  def check_skill_slots
    if equipped_skills.size > skill_slots
      equipped_skills.slice!(skill_slots..equipped_skills.size)
    end
  end
  #--------------------------------------------------------------------------
  # * Forget Skill
  # * ALIAS
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    forget_equipped_skill(skill_id)
    qskill_forget(skill_id)
  end
  #--------------------------------------------------------------------------
  # * NEW Forget Equipped Skill
  #--------------------------------------------------------------------------
  def forget_equipped_skill(skill_id)
    if equipped_skills.include?(skill_id)
      equipped_skills.delete(skill_id)
    end
  end
end
 
#==============================================================================
# ** Scene_Skill
#------------------------------------------------------------------------------
#  This class performs skill screen processing. Skills are handled as items for
# the sake of process sharing.
#==============================================================================
 
class Scene_Skill < Scene_ItemBase
  alias qskill_ss_ccw create_command_window
  alias qskill_ss_ciw create_item_window
  alias qskill_ss_up update
  #--------------------------------------------------------------------------
  # * Update Method
  # ~ Don't really like this, but needed to fix visibility issue.
  #--------------------------------------------------------------------------
  def update
    update_skillequip
    qskill_ss_up
  end
  #--------------------------------------------------------------------------
  # * NEW Update SkillEquip
  #--------------------------------------------------------------------------
  def update_skillequip
    case @command_window.command_name(@command_window.index)
    when Quasi::SkillEquip::NAMESKILL
      @skill_equip_window.show if !@skill_equip_window.visible
      @item_window.hide if @item_window.visible
    else
      @item_window.show if !@item_window.visible
      @skill_equip_window.hide if @skill_equip_window.visible
    end
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  # * ALIAS
  #--------------------------------------------------------------------------
  def create_command_window
    qskill_ss_ccw
    @command_window.set_handler(:sequip,   method(:command_sequip))
  end
  #--------------------------------------------------------------------------
  # * Create Skill type Window
  # * ALIAS
  #--------------------------------------------------------------------------
  def create_item_window
    qskill_ss_ciw
    create_skill_equip_window
  end
  #--------------------------------------------------------------------------
  # * NEW Create Skill Equip Window
  #--------------------------------------------------------------------------
  def create_skill_equip_window
    wx = @item_window.x
    wy = @item_window.y
    ww = @item_window.width
    wh = @item_window.height
    @skill_equip_window = Window_SkillEquip.new(wx, wy, ww, wh)
    @skill_equip_window.actor = @actor
    @skill_equip_window.viewport = @viewport
    @skill_equip_window.help_window = @help_window
    @skill_equip_window.set_handler(:ok,     method(:on_sequip_ok))
    @skill_equip_window.set_handler(:cancel, method(:on_sequip_cancel))
  end
  #--------------------------------------------------------------------------
  # * NEW Skill Equip Command
  #--------------------------------------------------------------------------
  def command_sequip
    @skill_equip_window.activate
    @skill_equip_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * NEW Skill Equip [OK]
  #--------------------------------------------------------------------------
  def on_sequip_ok
    if @skill_equip_window.item
      if @actor.equipped_skills.include?(@skill_equip_window.item.id)
        Sound.play_ok
        @actor.equipped_skills.delete(@skill_equip_window.item.id)
      else
        if @actor.equipped_skills.size >= @actor.skill_slots
          Sound.play_buzzer
        else
          Sound.play_ok
          @actor.equipped_skills.push(@skill_equip_window.item.id)
        end
      end
    end
    @status_window.refresh
    @skill_equip_window.refresh
    @skill_equip_window.activate
  end
  #--------------------------------------------------------------------------
  # * NEW Skill Equip [Cancel]
  #--------------------------------------------------------------------------
  def on_sequip_cancel
    @skill_equip_window.unselect
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
  alias skill_wsc_mkcmd make_command_list
  #--------------------------------------------------------------------------
  # * Create Command List
  # * ALIAS
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Quasi::SkillEquip::NAMESKILL, :sequip, true)
    skill_wsc_mkcmd
  end
end
 
#==============================================================================
# ** Window_SkillEquip (NEW)
#------------------------------------------------------------------------------
#  This window is for displaying a list of skills the player can equip.
#==============================================================================
 
class Window_SkillEquip < Window_Selectable
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
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
  end
  #--------------------------------------------------------------------------
  # * Create Skill List
  #--------------------------------------------------------------------------
  def make_item_list
    return if !@actor
    @data = []
    @actor.skills.each do |skill|
      if $imported["Quasi_Passive"]
        next if skill.passive
      end
      @data.push(skill)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if skill
      rect = item_rect(index)
      rect.width -= 4
      enable = @actor.equipped_skills.include?(skill.id)
      draw_item_name(skill, rect.x, rect.y, enable)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    text = item ? item.description : ""
    pl = @actor.equipped_skills.size
    pt = @actor.skill_slots
    text += "\n#{Quasi::SkillEquip::HELP}: #{pl}/#{pt}"
    @help_window.set_text(text)
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
# ** Window_SkillList
#------------------------------------------------------------------------------
#  This window is for displaying a list of available skills on the skill window.
#==============================================================================
 
class Window_SkillList < Window_Selectable
  #--------------------------------------------------------------------------
  # * Include in Skill List?
  # ** OVERWRITE **
  #  Hides skills unless they are equipped
  #--------------------------------------------------------------------------
  def include?(item)
    item && item.stype_id == @stype_id && @actor.equipped_skills.include?(item.id)
  end
end
 
#==============================================================================
# ** RPG::BaseItem
#==============================================================================
class RPG::BaseItem
  def skill_slots
    if @skill_slots.nil?
      @skill_slots = Quasi::regex(@note, /<skill_slots:(.*)>/i, :int, 0)
    end
    return @skill_slots
  end
end

else
  msgbox(sprintf("[Quasi Skill Equip] Requires Quasi module."))
end
