#==============================================================================
# ** Quasi Passive v 2.0
#  Require Module Quasi
#   http://code.quasixi.com/page/post/quasi+module/
#==============================================================================
#  Allows characters to learn and equip passive skills.  Passive skills are
# skills that act like buffs and increase parameters.  If you enable Passive
# Equip, then the buff will take place once you equip the skills, otherwise
# the buff will be active as long as the character knows the skill.
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v 2.0 - 11/14/14
#       - Rewritten
#       - Merged with Passive Equip
#==============================================================================
# Instructions:
#  Very simple to use, just needs a couple of notes tags!~
# The State(Passive) is added when the skill is learned, it is also removed
# when the skill is forgoten, unless you have ENABLE_EQUIP set to true, then
# the passive skill must be equiped in the skill menu.
#
#  For compatibility with Quasi Skill Equip and/or Quasi Skill Type Equip
# use Quasi Equip Patches:
#
#  http://code.quasixi.com/page/post/Quasi+Equip+Series+Patch/
#
#  That script should go below all 3 of those scripts.
#-----------------------------------------------------------------------------
module Quasi
  module Passive
    #--------------------------------------------------------------------------
    # Change this value to the Skill Type ID that you wish to hide
    #  Skills with this skill type id, aren't shown in battle.
    #--------------------------------------------------------------------------
    TYPE         = 3
    #--------------------------------------------------------------------------
    # Set to true if you want to allow passive equipping.
    # Equipping will be done inside the skill menu.
    #--------------------------------------------------------------------------
    ENABLE_EQUIP = true
    #--------------------------------------------------------------------------
    # Title to appear in the command window.
    #--------------------------------------------------------------------------
    NAMEPASSIVE  = "Passive"
    #--------------------------------------------------------------------------
    # What to show in the help window.
    # default shows "Passive Equiped: total/max"
    #--------------------------------------------------------------------------
    HELP         = "Passives Equiped" 
  end
end
#------------------------------------------------------------------------------
# * Skill Note Tag
#------------------------------------------------------------------------------
#    <passive: state_id>
# Replace state_id with the state you wish to add
#
#------------------------------------------------------------------------------
# * State Note Tag
#------------------------------------------------------------------------------
#     <passive>
# Just checks if the state is a passive state, if it is, it doesn't display on
# State icons, and can not be removed.
#
#------------------------------------------------------------------------------
# * Passive Slots Tag
#------------------------------------------------------------------------------
# <passive_slots: #>
# Can be placed in actors note box, or weapons/armor note box.  Default is 0.
#
# If an actor has 2 passive slots, and equips a weapon with 2 more slots.  You
# will be able to equip 4 passive skills.  If you unequip the weapon, the last
# 2 passive skills equipped, will be unequipped.
#==============================================================================#
# By Quasi (http://quasixi.com/) || (https://github.com/quasixi/RGSS3)
#  - 11/14/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
$imported = {} if $imported.nil?
$imported["Quasi_Passive"] = 2.0

if $imported["Quasi"]
#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This base class handles battlers. It mainly contains methods for calculating
# parameters. It is used as a super class of the Game_Battler class.
#==============================================================================

class Game_BattlerBase
  alias qpassive_init initialize
  attr_accessor   :equipped_passive
  #--------------------------------------------------------------------------
  # * Object Initialization
  # * ALIAS
  #--------------------------------------------------------------------------
  def initialize
    qpassive_init
    @equipped_passive = []
  end
  #--------------------------------------------------------------------------
  # * Get Current States as an Array of Icon Numbers
  # * OVERWRITE
  #--------------------------------------------------------------------------
  def state_icons
    icons = states.collect { |state| state.is_passive? ? 0 : state.icon_index }
    icons.delete(0)
    return icons
  end
  #--------------------------------------------------------------------------
  # * Clear State Information
  # * OVERWRITE
  #--------------------------------------------------------------------------
  def clear_states
    @states = [] if @states.nil?
    @state_turns = {} if @state_turns.nil?
    @state_steps = {} if @state_steps.nil?
    @states.delete_if{|state| !$data_states[state].is_passive?}
    @state_turns.delete_if{|state| !$data_states[state].is_passive?}
    @state_steps.delete_if{|state| !$data_states[state].is_passive?}
  end
end

#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  A battler class with methods for sprites and actions added. This class
# is used as a super class of the Game_Actor class and Game_Enemy class.
#==============================================================================

class Game_Battler < Game_BattlerBase
  alias qpassive_remove remove_state
  #--------------------------------------------------------------------------
  # * Remove State
  # * ALIAS
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    return if $data_states[state_id].is_passive?
    qpassive_remove(state_id)
  end
  #--------------------------------------------------------------------------
  # * NEW Remove State
  #--------------------------------------------------------------------------
  def remove_passive(state_id)
    if state?(state_id) && $data_states[state_id].is_passive?
      revive if state_id == death_state_id
      erase_state(state_id)
      refresh
      @result.removed_states.push(state_id).uniq!
    end
  end
end

#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It is used within the Game_Actors class
# ($game_actors) and is also referenced from the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  alias qpassive_learn learn_skill
  alias qpassive_forget forget_skill
  alias qpassive_change change_equip
  #--------------------------------------------------------------------------
  # * Change Equipment
  #     slot_id:  Equipment slot ID
  #     item:    Weapon/armor (remove equipment if nil)
  #--------------------------------------------------------------------------
  def change_equip(slot_id, item)
    qpassive_change(slot_id, item)
    check_passive_slots if Quasi::Passive::ENABLE_EQUIP
  end
  #--------------------------------------------------------------------------
  # * Learn Skill
  # * ALIAS
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    qpassive_learn(skill_id)
    learn_passive(skill_id)
  end
  #--------------------------------------------------------------------------
  # * Forget Skill
  # * ALIAS
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    forget_passive(skill_id)
    qpassive_forget(skill_id)
  end
  #--------------------------------------------------------------------------
  # * NEW Learn Passive
  #--------------------------------------------------------------------------
  def learn_passive(skill_id)
    if Quasi::Passive::ENABLE_EQUIP
      return unless equipped_passive.include?(skill_id)
    end
    return unless skill_learn?($data_skills[skill_id])
    passive = $data_skills[skill_id].passive
    add_new_state(passive) if passive
    reset_state_counts(passive) if passive
  end
  #--------------------------------------------------------------------------
  # * NEW Forget Passive
  #--------------------------------------------------------------------------
  def forget_passive(skill_id)
    if Quasi::Passive::ENABLE_EQUIP
      if equipped_passive.include?(skill_id)
        passive = $data_skills[skill_id].passive
        remove_passive(passive) if passive
        equipped_passive.delete(skill_id)
      end
    else
      passive = $data_skills[skill_id].passive
      remove_passive(passive) if passive
    end
  end
  #--------------------------------------------------------------------------
  # * NEW Passive Slots
  #--------------------------------------------------------------------------
  def passive_slots
    pslots = actor.passive_slots
    @equips.each {|eqp| next if eqp.object.nil? ; pslots += eqp.object.passive_slots}
    return pslots
  end
  #--------------------------------------------------------------------------
  # * NEW Check Passive Slots
  #--------------------------------------------------------------------------
  def check_passive_slots
    if equipped_passive.size > passive_slots
      equipped_passive.each_with_index do |passive, i|
        next if i < passive_slots
        forget_passive(passive)
      end
    end
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
    @actor.added_skill_types.sort.each do |stype_id|
      next if stype_id == Quasi::Passive::TYPE
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
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
  alias qpassive_ss_up update
  alias qpassive_ss_ccw create_command_window
  alias qpassive_ss_ciw create_item_window
  #--------------------------------------------------------------------------
  # * Update Method
  # * ALIAS
  #--------------------------------------------------------------------------
  def update
    if Quasi::Passive::ENABLE_EQUIP
      update_passive
    end
    qpassive_ss_up
  end
  #--------------------------------------------------------------------------
  # * NEW Update Passive
  #--------------------------------------------------------------------------
  def update_passive
    case @command_window.command_name(@command_window.index)
    when Quasi::Passive::NAMEPASSIVE
      @passive_window.show if !@passive_window.visible
      @item_window.hide if @item_window.visible
    else
      @item_window.show if !@item_window.visible
      @passive_window.hide if @passive_window.visible
    end
  end
  #--------------------------------------------------------------------------
  # * Create Command Window
  # * ALIAS
  #--------------------------------------------------------------------------
  def create_command_window
    qpassive_ss_ccw
    if Quasi::Passive::ENABLE_EQUIP
      @command_window.set_handler(:passive,   method(:command_passive))
    end
  end
  #--------------------------------------------------------------------------
  # * Create Skill type Window
  # * ALIAS
  #--------------------------------------------------------------------------
  def create_item_window
    qpassive_ss_ciw
    if Quasi::Passive::ENABLE_EQUIP
      create_passive_window
    end
  end
  #--------------------------------------------------------------------------
  # * NEW Create Passive Window
  #--------------------------------------------------------------------------
  def create_passive_window
    wx = @item_window.x
    wy = @item_window.y
    ww = @item_window.width
    wh = @item_window.height
    @passive_window = Window_PassiveList.new(wx, wy, ww, wh)
    @passive_window.actor = @actor
    @passive_window.viewport = @viewport
    @passive_window.help_window = @help_window
    @passive_window.set_handler(:ok,     method(:on_passive_ok))
    @passive_window.set_handler(:cancel, method(:on_passive_cancel))
  end
  #--------------------------------------------------------------------------
  # * NEW Passive Command
  #--------------------------------------------------------------------------
  def command_passive
    @passive_window.activate
    @passive_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * NEW Passive [OK]
  #--------------------------------------------------------------------------
  def on_passive_ok
    if @passive_window.item
      if @actor.equipped_passive.include?(@passive_window.item.id)
        Sound.play_ok
        @actor.forget_passive(@passive_window.item.id)
      else
        if @actor.equipped_passive.size >= @actor.passive_slots
          Sound.play_buzzer
        else
          Sound.play_ok
          @actor.equipped_passive.push(@passive_window.item.id)
          @actor.learn_passive(@passive_window.item.id) 
        end
      end
    end
    @status_window.refresh
    @passive_window.refresh
    @passive_window.activate
  end
  #--------------------------------------------------------------------------
  # * NEW Passive [Cancel]
  #--------------------------------------------------------------------------
  def on_passive_cancel
    @passive_window.unselect
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
  alias qpassive_wsc_mkcmd make_command_list
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    if Quasi::Passive::ENABLE_EQUIP
      make_passive_list
    else
      qpassive_wsc_mkcmd
    end
  end
  #--------------------------------------------------------------------------
  # * NEW Create Command with Equip
  #--------------------------------------------------------------------------
  def make_passive_list
    return unless @actor
    add_command(Quasi::Passive::NAMEPASSIVE, :passive, true)
    @actor.added_skill_types.sort.each do |stype_id|
      next if stype_id == Quasi::Passive::TYPE
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
end
 
#==============================================================================
# ** Window_PassiveList (NEW)
#------------------------------------------------------------------------------
#  This window is for displaying a list of available passive skills
#  on the skill window.
#==============================================================================
 
class Window_PassiveList < Window_Selectable
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
      next unless skill.passive
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
      enable = @actor.equipped_passive.include?(skill.id)
      draw_item_name(skill, rect.x, rect.y, enable)
    end
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    text = item ? item.description : ""
    pl = @actor.equipped_passive.size
    pt = @actor.passive_slots
    text += "\n#{Quasi::Passive::HELP}: #{pl}/#{pt}"
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
# ** RPG::BaseItem
#==============================================================================

class RPG::BaseItem
  def passive_slots
    if @passive_slots.nil?
      @passive_slots = Quasi::regex(@note, /<passive_slots:(.*)/i, :int, 0)
    end
    return @passive_slots
  end
end

#==============================================================================
# ** RPG::Skill
#==============================================================================

class RPG::Skill
  def passive
    if @passive.nil?
      @passive = Quasi::regex(@note, /<passive:(.*)/i, :int, false)
    end
    return @passive
  end
end

#==============================================================================
# ** RPG::State
#==============================================================================

class RPG::State
  def is_passive?
    if @is_passive.nil?
      @is_passive = Quasi::regex(@note, /<(?i:passive)>/)
    end
    return @is_passive
  end
end

else
  msgbox(sprintf("[Quasi Passive] Requires Quasi module."))
end
