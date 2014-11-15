#==============================================================================
# ** Quasi Equip Series Patch v1.0
#==============================================================================
#  Allows Quasi Passive, Quasi Skill Equip, and Quasi Skill Type Equip
# to work together.  There is no point of using this if you are only
# using one of the above!  But highly recommended you use this if
# you are using atleast 2 of them together.
#==============================================================================
# Change Log
#------------------------------------------------------------------------------
# v 1.0 - 11/14/14
#       - Released
#==============================================================================
# Instructions:
#  Paste this below Quasi Passive, Quasi Skill Equip, and Quasi Skill Type Equip
# No other steps are needed.
#==============================================================================#
# By Quasi (http://quasixi.com/)  || (https://github.com/quasixi/RGSS3)
#  - 11/14/14
#==============================================================================#
#   ** Stop! Do not edit anything below, unless you know what you      **
#   ** are doing!                                                      **
#==============================================================================#
#==============================================================================
# ** Scene_Skill
#------------------------------------------------------------------------------
#  This class performs skill screen processing. Skills are handled as items for
# the sake of process sharing.
#==============================================================================
 
class Scene_Skill < Scene_ItemBase
  alias qeqppatch_ss_start start
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    qeqppatch_ss_start
    if $imported["Quasi_SkillEquip"]
      @sequip = Quasi::SkillEquip::NAMESKILL
    else
      @sequip = ""
    end
    if $imported["Quasi_STypeEquip"]
      @stype = Quasi::STypeEquip::NAME
    else
      @stype = ""
    end
    if $imported["Quasi_Passive"] && Quasi::Passive::ENABLE_EQUIP
      @passive = Quasi::Passive::NAMEPASSIVE
    else
      @passive = ""
    end
  end
  #--------------------------------------------------------------------------
  # * Update Method
  #--------------------------------------------------------------------------
  def update
    super
    case @command_window.command_name(@command_window.index)
    when @sequip
      @skill_equip_window.show if !@skill_equip_window.visible
      @item_window.hide if @item_window.visible
      if $imported["Quasi_STypeEquip"]
        @stype_window.hide if @stype_window.visible
      end
      if $imported["Quasi_Passive"] && Quasi::Passive::ENABLE_EQUIP
        @passive_window.hide if @passive_window.visible
      end
    when @stype
      @stype_window.show if !@stype_window.visible
      @item_window.hide if @item_window.visible
      if $imported["Quasi_SkillEquip"]
        @skill_equip_window.hide if @skill_equip_window.visible
      end
      if $imported["Quasi_Passive"] && Quasi::Passive::ENABLE_EQUIP
        @passive_window.hide if @passive_window.visible
      end
    when @passive
      @passive_window.show if !@passive_window.visible
      @item_window.hide if @item_window.visible
      if $imported["Quasi_SkillEquip"]
        @skill_equip_window.hide if @skill_equip_window.visible
      end
      if $imported["Quasi_STypeEquip"]
        @stype_window.hide if @stype_window.visible
      end
    else
      @item_window.show if !@item_window.visible
      if $imported["Quasi_Passive"] && Quasi::Passive::ENABLE_EQUIP
        @passive_window.hide if @passive_window.visible
      end
      if $imported["Quasi_STypeEquip"]
        @stype_window.hide if @stype_window.visible
      end
      if $imported["Quasi_SkillEquip"]
        @skill_equip_window.hide if @skill_equip_window.visible
      end
    end
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
  #--------------------------------------------------------------------------
  def include?(item)
    if $imported["Quasi_SkillEquip"]
      if $imported["Quasi_Passive"] && !Quasi::Passive::ENABLE_EQUIP
        pass = @actor.equipped_skills.include?(item.id) || @stype_id == Quasi::Passive::TYPE
      else
        pass = @actor.equipped_skills.include?(item.id)
      end
      return item && item.stype_id == @stype_id && pass
    end
    return item && item.stype_id == @stype_id
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
    if $imported["Quasi_STypeEquip"]
      add_command(Quasi::STypeEquip::NAME, :stype, true)
    end
    if $imported["Quasi_SkillEquip"]
      add_command(Quasi::SkillEquip::NAMESKILL, :sequip, true)
    end
    if $imported["Quasi_Passive"]
      if Quasi::Passive::ENABLE_EQUIP
        if !$imported["Quasi_STypeEquip"]
          make_passive_list
        else
          add_command(Quasi::Passive::NAMEPASSIVE, :passive, true)
          make_stype_list
        end
      else
        if !$imported["Quasi_STypeEquip"]
          make_normal_list
        else
          make_stype_list
        end
      end
      return
    end
    if $imported["Quasi_STypeEquip"]
      make_stype_list
    else
      make_normal_list
    end
  end
  #--------------------------------------------------------------------------
  # * NEW Make SType List
  #--------------------------------------------------------------------------
  def make_stype_list
    return unless @actor
    if $imported["Quasi_Passive"] && !Quasi::Passive::ENABLE_EQUIP
      name = $data_system.skill_types[Quasi::Passive::TYPE]
      add_command(name, :skill, true, Quasi::Passive::TYPE)
    end
    @actor.equipped_skill_types.sort.each do |stype_id|
      if $imported["Quasi_Passive"]
        next if stype_id == Quasi::Passive::TYPE
      end
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
  #--------------------------------------------------------------------------
  # * NEW Make Normal List
  #--------------------------------------------------------------------------
  def make_normal_list
    return unless @actor
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
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
    if $imported["Quasi_STypeEquip"]
      @actor.equipped_skill_types.sort.each do |stype_id|
        name = $data_system.skill_types[stype_id]
        add_command(name, :skill, true, stype_id)
      end
    elsif $imported["Quasi_Passive"]
      @actor.added_skill_types.sort.each do |stype_id|
        next if stype_id == Quasi::Passive::TYPE
        name = $data_system.skill_types[stype_id]
        add_command(name, :skill, true, stype_id)
      end
    else
      @actor.added_skill_types.sort.each do |stype_id|
        name = $data_system.skill_types[stype_id]
        add_command(name, :skill, true, stype_id)
      end
    end
  end
end
