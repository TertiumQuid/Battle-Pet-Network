class Challenge < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  belongs_to :attacker, :class_name => "Pet"
  belongs_to :defender, :class_name => "Pet"
  belongs_to :attacker_strategy, :class_name => "Strategy"
  belongs_to :defender_strategy, :class_name => "Strategy"
  
  validates_presence_of :attacker_strategy
  
  has_one :battle

  attr_accessor :pack_id
  
  validates_presence_of :status, :challenge_type, :attacker_id, :attacker_strategy
  validates_length_of :message, :in => 3..256, :allow_blank => true
  validates_inclusion_of :status, :in => %w(issued refused canceled expired resolved)
  validates_inclusion_of :challenge_type, :in => %w(1v1 1v0 1vG)
  
  accepts_nested_attributes_for :attacker_strategy, :allow_destroy => false
  accepts_nested_attributes_for :defender_strategy, :allow_destroy => false
  
  validate :validates_different_combatants
  validate :validates_no_existing_challenge
  validate :validates_prowling
  validate :validates_status_update
  
  before_validation_on_create :set_challenge_type
  after_validation :log_refusal
  after_create :log_challenge
  
  named_scope :open, :conditions => "status = 'issued' AND challenge_type = '1v0'", :order => 'created_at DESC'
  named_scope :issued, :conditions => "status = 'issued'"
  named_scope :resolved, :conditions => "status = 'resolved'"  
  named_scope :for_attacker, lambda { |attacker_id| 
    { :conditions => ["attacker_id = ?", attacker_id] }
  }  
  named_scope :for_defender, lambda { |defender_id| 
    { :conditions => ["defender_id = ?", defender_id] }
  }
  named_scope :for_combatants, lambda { |first_id, second_id| 
    { :conditions => ["? IN (attacker_id, defender_id) AND ? IN (attacker_id, defender_id)", first_id, second_id] }
  }
  named_scope :excluding, lambda { |ids| 
    { :conditions => ["id NOT IN (?)", ids.is_a?(Array) ? ids : [ids] ] }
  }      
  
  class << self
    def find_issued_for_defender(id, pet_id)
      challenge = Challenge.issued.find_by_id(id)
      if challenge && (challenge.defender_id.blank? || challenge.defender_id == pet_id)
        challenge.defender_id = pet_id
        return challenge 
      else
        return nil
      end
      
      assign pet as defender if open
    end
  end
  
  def after_initialize(*args)
    self.status ||= 'issued' if attributes.include?(:status)
  end

  def validates_different_combatants
    errors.add_to_base("cannot challenge self") if attacker_id == defender_id
  end
  
  def validates_prowling
    errors.add(:attacker_id, "must be prowling to issue challenge") if new_record? && attacker && !attacker.prowling?
    errors.add(:defender_id, "must be prowling to accept challenge") if !new_record? && defender && !defender.prowling?
  end
  
  def validates_no_existing_challenge
    return true unless new_record?
    existing_challenge = Challenge.exists?(
      ["status = 'issued' AND ((attacker_id = ? AND defender_id = ?) OR (attacker_id = ? AND defender_id = ?))", 
        attacker_id, defender_id, defender_id, attacker_id])
    errors.add_to_base("An outstanding challenge already exists for those pets.") if existing_challenge
  end
  
  def validates_status_update
    return true if new_record? || status != 'issued'
    errors.add(:defender_strategy_id, "maneuvers cannot be empty") if defender_strategy.blank? || 
                                                                                        defender_strategy.maneuvers.blank?
  end
  
  def open?
    challenge_type == "1v0"
  end
  
  def description
    text = "#{time_ago_in_words(created_at)} ago #{attacker.name} challenged #{defender.name} "
    
    case status
      when "resolved"
        if battle.winner_id == attacker_id
          text = "#{text} and won the battle."
        elsif battle.winner_id == defender_id
          text = "#{text} and was defeated."
        else
          text = "#{text} and fought to a draw."
        end
    end
    return text
  end
  
  def battle!
    return if attacker_strategy_id.blank? || defender_strategy_id.blank?
    create_battle
  end
  
  def set_challenge_type
    if attacker_id && defender_id
      self.challenge_type = "1v1"
    elsif attacker_id && defender_id.blank? && pack_id
    elsif attacker_id && defender_id.blank?
      self.challenge_type = "1v0"
    end
  end
  
  def log_challenge
    ActivityStream.log! 'combat',"challenge-#{challenge_type}", attacker, defender, self
  end
  
  def log_refusal
    return if new_record? || !status_changed? || status_was != 'issued' || status != 'refused'
    ActivityStream.log! 'combat', 'refused', defender, attacker, self
  end
end