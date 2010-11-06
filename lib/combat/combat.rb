module Combat
  require 'action_view/test_case'
  include CombatLogger
  include CombatActions
    
  def self.included(base)
    base.send :validate, :validates_combat
    base.send :after_validation, :run_combat
  end
  
  attr_accessor :current_round
  attr_accessor :attacker_action, :defender_action
  attr_accessor :attacker_damage, :defender_damage
  
  class << self
    def calculate_experience(power, level_rank, opponent_level_rank, did_win)
      outcome = did_win ? 1 : 0 
      outcome_award = (power * outcome)
      
      divisor = AppConfig.experience.handicap_divisor
      delta = opponent_level_rank - level_rank
      delta = 1 if delta == 0
      combat_award = ( (delta.to_f / divisor.to_f) * power.to_f).ceil
      
      minimum_award = AppConfig.experience.minimum_award
      total_award = (outcome_award + combat_award).to_i
      return [minimum_award, total_award].max
    end
  end
  
  def initialize_combat
    @current_round = 0
    @attacker_damage = 0
    @defender_damage = 0
    @attacker_action = nil
    @defender_action = nil
  end
    
  def attacker
    return @_attacker if defined?(@_attacker)
    if self.respond_to?(:challenge)
      @_attacker = challenge.attacker
    elsif self.respond_to?(:hunters)
      @_attacker = hunter ? hunter.pet : nil
    end
    return @_attacker
  end
  
  def defender
    if respond_to?(:challenge)
      return challenge.defender
    elsif respond_to?(:hunters)
      return sentient
    end
  end
  
  def combatants
    [attacker,defender]
  end
  
  def validates_combat
    return true unless combat_needs_to_occur?
    
    errors.add_to_base("attacker needed") if attacker.blank?
    errors.add_to_base("defender needed") if defender.blank?
    
    return errors.empty?
  end
  
  def run_combat
    logger.info "combat: run_combat: #{combat_needs_to_occur?} && #{validates_combat}"
    return unless combat_needs_to_occur? && validates_combat
    initialize_combat
    
    combatants.each do |c| 
      log_combatant_status(c)
      log_gear(c)
    end
    while combat_in_progress?
      reset_actions
      @current_round = @current_round + 1
      logger.info "combat: round #{@current_round}"
      exhaust_combatants
      
      results = CombatActions::Resolution.new(attacker, action_for(attacker), defender, action_for(defender))
      
      logger.info "combat: results - #{results.inspect}"
      
      attacker.current_health = [attacker.current_health - results.second_damage,0].max
      defender.current_health = [defender.current_health - results.first_damage,0].max
      logger.info "combat: attacker health #{attacker.current_health}, defender health #{defender.current_health}"
      logger.info "combat: attacker end #{attacker.current_endurance}, defender end #{defender.current_endurance}"      
      
      log_round(results)
    end
    
    set_outcome if respond_to?(:set_outcome)
    log_outcome
    combatants.each do |c| 
      log_combatant_status(c,'ended')
    end
    restore_combatants_condition
    save_combatants
    respond_to?(:award!) ? award! : award_combatants
  end
  
  def reset_actions
    @attacker_action = nil
    @defender_action = nil
  end
  
  def exhaust_combatants
    combatants.each do |c|
      cost = action_for(c).endurance_cost
      c.current_endurance = [c.current_endurance - cost, 0].max
    end
  end  
  
  def restore_combatants_condition
    combatants.each do |c|
      next unless c.is_a? Pet
      if combatant_defeated?(c)
        c.current_health = [c.current_health, (c.total_health / 2)].max
      else  
        c.current_health = c.total_health
      end
    end
  end
  
  def award_combatants
    return if end_result == EndResult::BOTH_EXHAUSTED
    combatants.each do |c|
      next unless c.is_a?(Pet)
      c.award_experience! experience_for_combatant(c)
    end
  end
  
  def experience_for_combatant(c)
    return 0 unless c.is_a?(Pet)
    
    did_win = !combatant_defeated?(c)
    power = strategy_for(c).total_power
    level = c.level_rank_count
    opponent = opponent_for(c)
    other_level = opponent.is_a?(Pet) ? opponent.level_rank_count : 1
    
    experience = Combat.calculate_experience(power, level, other_level, did_win)
    strategy = strategy_for(c)
    favorite_action_bonus = (did_win ? strategy.favorite_action_experience_bonus : 0)
    intelligence_bonus = (did_win ? c.intelligence_bonus_count : 0)
    
    return experience + favorite_action_bonus + intelligence_bonus
  end
  
  def save_combatants
    combatants.each do |c|
      c.save if c.is_a? Pet
    end
  end

  def combat_needs_to_occur?
    if self.respond_to?(:challenge)
      return self.new_record?
    elsif self.respond_to?(:hunters)
      return status == "started"
    end
  end
  
  def combat_in_progress?
    in_progress = attacker.current_endurance > 0 &&
                  defender.current_endurance > 0 &&
                  attacker.current_health > 0 &&
                  defender.current_health > 0
    return in_progress
  end
  
  def opponent_for(combatant)
    if combatant == attacker
      return defender
    elsif combatant == defender
      return attacker
    end
    return nil
  end
  
  def action_for(combatant)
    # cached actions, cleared each round with the reset_actions method
    return @attacker_action if (combatant == attacker) && !@attacker_action.nil?
    return @defender_action if (combatant == defender) && !@defender_action.nil?
    
    action = if combatant.is_a?(Sentient)
      combatant.strategy.random_maneuver.action
    else 
      maneuvers = strategy_for(combatant).maneuvers
      maneuvers[ @current_round % maneuvers.size ].action
    end
    if (combatant == attacker)
      @attacker_action = action
    elsif (combatant == defender)
      @defender_action = action
    end
    
    return action
  end
  
  def strategy_for(combatant)
    if self.respond_to?(:challenge)
      return challenge.attacker_strategy if (combatant == attacker) 
      return challenge.defender_strategy if (combatant == defender)
    elsif self.respond_to?(:hunters)
      return hunter.strategy if (combatant == attacker) 
      return combatant.strategy if (combatant == defender)
    end
  end
  
  def combatant_defeated?(combatant)
    combatant.current_endurance == 0 || combatant.current_health == 0
  end
  
  def end_result
    return EndResult::BOTH_EXHAUSTED if (attacker.current_endurance + defender.current_endurance == 0)
    return EndResult::BOTH_UNCONSCIOUS if (attacker.current_health + defender.current_health == 0)
    return EndResult::ATTACKER_WON if (defender.current_health == 0 || defender.current_endurance == 0)
    return EndResult::DEFENDER_WON if (attacker.current_health == 0 || attacker.current_endurance == 0)
    nil
  end
  
  class EndResult
    BOTH_EXHAUSTED = 1
    BOTH_UNCONSCIOUS = 2
    ATTACKER_WON = 3
    DEFENDER_WON = 4
  end  
end