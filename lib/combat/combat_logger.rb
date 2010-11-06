module Combat::CombatLogger
  require 'action_view/test_case'
  include ActionView::Helpers::AssetTagHelper
  
  LOG_STRUCT = {:rounds => [], 
                :outcome => nil, 
                :status => {:entered => [], :ended => []},
                :gear => [],
                :attacker_awards => {:experience => [], :kibble => []}, 
                :defender_awards => {:experience => []}}
  
  def log_advancement(pet)
    log = "#{pet.name} obtained level #{pet.level_rank_count} " <<
          "and earned +#{pet.level.advancement_amount} #{pet.level.advancement_type}."
    if pet == attacker
      logs[:attacker_awards][:experience] << log
    elsif pet == defender
      logs[:defender_awards][:experience] << log
    end
    return log
  end
  
  def log_gear(pet)
    return nil unless pet.is_a?(Pet)
    gear = pet.gear_list
    return nil if gear.blank?

    log = "#{pet.name} carried #{gear} into battle." 
    logs[:gear] << log
    return log
  end
  
  def log_kibble(pet,kibble)
    log = "#{pet.name} earned #{kibble} kibble"
    logs[:attacker_awards][:kibble] << log if pet == attacker
    return log
  end
  
  def log_outcome
    log = "undecided"
    if combatant_defeated?(attacker) and combatant_defeated?(defender)
      if defender.current_endurance + attacker.current_endurance == 0
        log = "Both #{named(attacker)} and #{named(defender)} collapsed in exhaustion."
      elsif defender.current_health + attacker.current_health == 0
        log = "Both #{named(attacker)} and #{named(defender)} fell unconcious from their wounds."
      end
    elsif !combatant_defeated?(attacker) and combatant_defeated?(defender)    
      if defender.current_endurance == 0
        log = "The heat of battle was too much and #{named(defender)} collapsed from exhaustion."
      elsif defender.current_health == 0
        log = "#{named(attacker)}'s final move sent #{named(defender)} to the ground defeated."
      end
    elsif combatant_defeated?(attacker) and !combatant_defeated?(defender)    
      if attacker.current_endurance == 0
        log = "The heat of battle was too much and #{named(attacker)} collapsed from exhaustion."
      elsif attacker.current_health == 0
        log = "#{named(defender)}'s final move sent #{named(attacker)} to the ground defeated."
      end
    end
    logs[:outcome] = log
    return log
  end
  
  def log_combatant_status(combatant,state='entered')
    return nil unless combatant.is_a?(Pet)
    log = "#{named(combatant)} #{state} the battle with #{combatant.current_health} health and #{combatant.current_endurance} endurance."
    logs[:status][state.to_sym] << log
    return log
  end
  
  def log_round(res)
    log = case res.description
      when Combat::CombatActions::Resolution::Description::ALL_ATTACK
        "#{named(res.first)} #{verbed(res.first_action)} for #{res.first_damage} " <<
        "and #{named(res.second)} #{verbed(res.second_action)} for #{res.second_damage}."
      when Combat::CombatActions::Resolution::Description::ALL_DEFEND
        "#{named(res.first)} #{verbed(res.first_action)} and #{named(res.second)} #{verbed(res.second_action)} " <<
        "but neither struck a blow."
      when Combat::CombatActions::Resolution::Description::ONE_DEFEND_CUT_TWO_ATTACK
        "#{named(res.first)} UNDERCUT #{named(res.second)}'s misplaced #{res.second_action.name} " <<
        "with a painful #{res.first_action.name} for #{res.first_damage}."
      when Combat::CombatActions::Resolution::Description::ONE_ATTACK_HIT_TWO_DEFEND
        "#{named(res.first)} #{verbed(res.first_action)} through " << 
        "#{named(res.second)}'s helpless #{res.second_action.name} " <<
        "for #{res.first_damage}."
      when Combat::CombatActions::Resolution::Description::ONE_ATTACK_CUT_TWO_DEFEND  
        "#{named(res.second)} UNDERCUT #{named(res.first)}'s rash #{res.first_action.name} " <<
        "with a countering #{res.second_action.name} for #{res.second_damage}."
      when Combat::CombatActions::Resolution::Description::ONE_ATTACK_HIT_TWO_DEFENDED
        "#{named(res.first)} #{verbed(res.first_action)} for #{res.first_damage} as " <<
        "#{named(res.second)} #{verbed(res.second_action)} in defense."
      when Combat::CombatActions::Resolution::Description::TWO_DEFEND_CUT_TWO_ATTACK
        "#{named(res.second)} UNDERCUT #{named(res.first)}'s misplaced #{res.first_action.name} " <<
        "with a painful #{res.second_action.name} for #{res.second_damage}."
      when Combat::CombatActions::Resolution::Description::TWO_ATTACK_HIT_TWO_DEFEND
        "#{named(res.first)} #{verbed(res.first_action)} through " << 
        "#{named(res.second)}'s helpless #{res.second_action.name} " <<
        "for #{res.first_damage}."
      when Combat::CombatActions::Resolution::Description::TWO_ATTACK_CUT_TWO_DEFEND 
        "#{named(res.first)} UNDERCUT #{named(res.second)}'s rash #{res.second_action.name} " <<
        "with a countering #{res.first_action.name} for #{res.first_damage}."
      when Combat::CombatActions::Resolution::Description::TWO_ATTACK_HIT_TWO_DEFENDED
        "#{named(res.second)} #{verbed(res.second_action)} for #{res.second_damage} as " <<
        "#{named(res.first)} #{verbed(res.first_action)} in defense."
    end
    log = {:attacker_action => res.first_action.slug, :defender_action => res.second_action.slug, :description => log}
    logs[:rounds] << log
    return log
  end
  
  def named(combatant)
    combatant.is_a?(Sentient) ? "the #{combatant.name.downcase}" : combatant.name
  end
  
  def verbed(action)
    text = action.name
    if text.match /te$/
      return text.gsub(/te$/,'t')
    elsif text.match /t$/
      return text.gsub(/t$/,'tted')
    elsif text.match /e$/
      return text.gsub(/e$/,'ed')
    elsif text.match /p$/
      return text.gsub(/p$/,'pt')
    else
      return "#{text}ed"
    end
  end
end