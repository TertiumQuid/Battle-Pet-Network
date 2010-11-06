class Battle < ActiveRecord::Base
  include Combat
  serialize :logs
  
  belongs_to :challenge
  belongs_to :winner, :class_name => "Pet", :foreign_key => "winner_id", :select => Pet::SELECT_BASICS
  
  after_create :resolve_challenge, :update_combatant_counters
  
  def after_initialize(*args)
    self.logs ||= Combat::CombatLogger::LOG_STRUCT
  end
  
  def resolve_challenge
    challenge.update_attribute(:status,"resolved")
  end

  def update_combatant_counters
    combatants.each do |c|
      if combatant_defeated?(attacker) && combatant_defeated?(defender)
        c.update_attribute(:draws_count, c.draws_count + 1)
      else
        if combatant_defeated?(c)
          c.update_attribute(:loses_count, c.loses_count + 1)
        else
          c.update_attribute(:wins_count, c.wins_count + 1)
        end
      end
    end
  end
  
  def set_outcome
    if !combatant_defeated?(attacker) && combatant_defeated?(defender)
      self.winner_id = attacker.id
    elsif combatant_defeated?(attacker) && !combatant_defeated?(defender)
      self.winner_id = defender.id
    end   
  end
end